#!/usr/bin/env python3
"""lz_check.py — landing zone health check for DBAs ("OCI for DBAs", Book 1, Chapter 4).

Reads (never changes) an OCI tenancy and reports what is missing or risky before a migration:
public subnets, open listener/SSH ports, missing NSGs or Service Gateway, public buckets,
Autonomous databases reachable from anywhere, no budget, no Vault, workloads in the root compartment.

Run it in OCI Cloud Shell (no setup needed) or anywhere with ~/.oci/config:
    python3 lz_check.py                      # whole tenancy, home region
    python3 lz_check.py --compartment meridian-lz
    python3 lz_check.py --json > report.json
Exit code: 0 = no FAIL, 1 = at least one FAIL.
"""
import argparse
import json
import os
import sys

RISKY_PORTS = {22: "SSH", 1521: "SQL*Net", 1522: "SQL*Net", 2484: "TCPS", 3389: "RDP"}
ANYWHERE = "0.0.0.0/0"


# ------------------------------------------------------------------ rules (pure functions, no OCI calls)
def _ports(tcp_options):
    if not tcp_options or not tcp_options.get("min"):
        return set(RISKY_PORTS)              # no port range = all ports
    return {p for p in RISKY_PORTS if tcp_options["min"] <= p <= tcp_options["max"]}


def check(inv):
    """inv: plain-dict inventory (see gather()). Returns a list of findings."""
    out = []

    def add(sev, area, item, msg):
        out.append({"severity": sev, "area": area, "item": item, "finding": msg})

    root = inv["tenancy_id"]
    for r in inv["instances"] + inv["vcns"] + inv["adbs"]:
        if r["compartment_id"] == root:
            add("WARN", "compartments", r["name"], "lives in the root compartment — move it into a workload compartment")

    names = {}
    for v in inv["vcns"]:
        names.setdefault((v["compartment_id"], v["name"]), []).append(v)
    for (_, name), vs in names.items():
        if len(vs) > 1:
            add("WARN", "network", name, f"{len(vs)} VCNs share this name in one compartment — one is probably a leftover")

    for s in inv["subnets"]:
        if not s["private"]:
            sev = "FAIL" if "db" in s["name"].lower() else "WARN"
            add(sev, "network", s["name"], "public subnet (public IPs allowed) — databases belong in private subnets")

    for sl in inv["security_lists"]:
        for rule in sl["ingress"]:
            if rule["source"] == ANYWHERE and rule["protocol"] in ("6", "all"):
                for p in sorted(_ports(rule.get("tcp"))):
                    add("FAIL", "network", sl["name"], f"security list allows {RISKY_PORTS[p]} ({p}) from {ANYWHERE}")

    for n in inv["nsg_rules"]:
        if n["direction"] == "INGRESS" and n["source"] == ANYWHERE and n["protocol"] in ("6", "all"):
            for p in sorted(_ports(n.get("tcp"))):
                add("FAIL", "network", n["nsg"], f"NSG allows {RISKY_PORTS[p]} ({p}) from {ANYWHERE}")

    for v in inv["vcns"]:
        if not any(n["vcn_id"] == v["id"] for n in inv["nsgs"]):
            add("WARN", "network", v["name"], "no network security groups — all access is controlled by subnet-wide security lists")
        if not any(g["vcn_id"] == v["id"] for g in inv["service_gateways"]):
            add("WARN", "network", v["name"], "no Service Gateway — backups to Object Storage go over the internet or NAT")

    for b in inv["buckets"]:
        if b["public_access_type"] != "NoPublicAccess":
            add("FAIL", "storage", b["name"], f"bucket is public ({b['public_access_type']})")

    for a in inv["adbs"]:
        if not a["private_endpoint"] and not a["acl"]:
            add("WARN", "database", a["name"], "Autonomous database accepts connections from any IP — add an access control list or a private endpoint")

    for b in inv["bastions"]:
        if ANYWHERE in b["allow_list"]:
            add("WARN", "access", b["name"], "Bastion accepts sessions from any IP — limit it to your office or VPN egress IP")

    if not inv["bastions"]:
        add("INFO", "access", "-", "no Bastion service — admins reach private hosts some other way (check how)")
    if not inv["vaults"]:
        add("WARN", "security", "-", "no Vault — TDE and secrets use Oracle-managed keys only")
    if not inv["budgets"]:
        add("WARN", "cost", "-", "no budget covers this scope — forgotten clones will not be noticed")
    if inv.get("cloud_guard") not in ("ENABLED", None):
        add("INFO", "security", "-", f"Cloud Guard is {inv['cloud_guard']}")
    if not any(f["severity"] in ("FAIL", "WARN") for f in out):
        add("PASS", "all", "-", "no issues found")
    order = {"FAIL": 0, "WARN": 1, "INFO": 2, "PASS": 3}
    return sorted(out, key=lambda f: (order[f["severity"]], f["area"], f["item"]))


# ------------------------------------------------------------------ OCI access
def _clients():
    import oci  # imported here so the rules can be tested without the SDK
    cfg_file = os.environ.get("OCI_CONFIG_FILE", oci.config.DEFAULT_LOCATION)
    profile = os.environ.get("OCI_CONFIG_PROFILE", "DEFAULT")
    config = oci.config.from_file(cfg_file, profile)
    kw = {}
    if config.get("delegation_token_file"):          # OCI Cloud Shell
        token = open(os.path.expanduser(config["delegation_token_file"])).read().strip()
        kw["signer"] = oci.auth.signers.InstancePrincipalsDelegationTokenSigner(delegation_token=token)
    mk = lambda cls: cls(config, **kw)  # noqa: E731
    return oci, config, {
        "id": mk(oci.identity.IdentityClient), "vn": mk(oci.core.VirtualNetworkClient),
        "cp": mk(oci.core.ComputeClient), "os": mk(oci.object_storage.ObjectStorageClient),
        "ba": mk(oci.bastion.BastionClient), "bu": mk(oci.budget.BudgetClient),
        "kv": mk(oci.key_management.KmsVaultClient), "db": mk(oci.database.DatabaseClient),
        "cg": mk(oci.cloud_guard.CloudGuardClient),
    }


def gather(scope_name=None):
    oci, config, c = _clients()
    allp = oci.pagination.list_call_get_all_results
    tenancy = config["tenancy"]
    comps = [x for x in allp(c["id"].list_compartments, tenancy, compartment_id_in_subtree=True,
                             access_level="ACCESSIBLE", lifecycle_state="ACTIVE").data]
    if scope_name:
        top = [x for x in comps if x.name == scope_name or x.id == scope_name]
        if not top:
            sys.exit(f"compartment {scope_name!r} not found")
        keep, frontier = {top[0].id}, [top[0].id]
        while frontier:
            nxt = [x.id for x in comps if x.compartment_id in frontier]
            keep.update(nxt)
            frontier = nxt
        scope = keep
    else:
        scope = {tenancy} | {x.id for x in comps}

    inv = {k: [] for k in ("instances", "vcns", "subnets", "security_lists", "nsgs", "nsg_rules",
                           "service_gateways", "buckets", "adbs", "bastions", "vaults")}
    inv["tenancy_id"] = tenancy
    ns = c["os"].get_namespace().data
    for cid in scope:
        for i in allp(c["cp"].list_instances, cid).data:
            if i.lifecycle_state != "TERMINATED":
                inv["instances"].append({"name": i.display_name, "compartment_id": cid})
        for v in allp(c["vn"].list_vcns, cid).data:
            inv["vcns"].append({"id": v.id, "name": v.display_name, "compartment_id": cid})
        for s in allp(c["vn"].list_subnets, cid).data:
            inv["subnets"].append({"name": s.display_name, "private": bool(s.prohibit_public_ip_on_vnic)})
        for sl in allp(c["vn"].list_security_lists, cid).data:
            rules = [{"source": r.source, "protocol": r.protocol,
                      "tcp": ({"min": r.tcp_options.destination_port_range.min,
                               "max": r.tcp_options.destination_port_range.max}
                              if r.tcp_options and r.tcp_options.destination_port_range else None)}
                     for r in sl.ingress_security_rules or []]
            inv["security_lists"].append({"name": sl.display_name, "ingress": rules})
        for n in allp(c["vn"].list_network_security_groups, compartment_id=cid).data:
            inv["nsgs"].append({"id": n.id, "name": n.display_name, "vcn_id": n.vcn_id})
            for r in allp(c["vn"].list_network_security_group_security_rules, n.id).data:
                rng = r.tcp_options.destination_port_range if r.tcp_options else None
                inv["nsg_rules"].append({"nsg": n.display_name, "direction": r.direction, "source": r.source,
                                         "protocol": r.protocol,
                                         "tcp": {"min": rng.min, "max": rng.max} if rng else None})
        for g in allp(c["vn"].list_service_gateways, cid).data:
            inv["service_gateways"].append({"vcn_id": g.vcn_id})
        for b in allp(c["os"].list_buckets, ns, cid).data:
            full = c["os"].get_bucket(ns, b.name).data
            inv["buckets"].append({"name": b.name, "public_access_type": full.public_access_type})
        for a in allp(c["db"].list_autonomous_databases, cid).data:
            if a.lifecycle_state != "TERMINATED":
                inv["adbs"].append({"name": a.display_name, "compartment_id": cid,
                                    "private_endpoint": bool(a.private_endpoint or a.subnet_id),
                                    "acl": list(a.whitelisted_ips or [])})
        for b in allp(c["ba"].list_bastions, cid).data:
            full = c["ba"].get_bastion(b.id).data
            inv["bastions"].append({"name": full.name, "allow_list": list(full.client_cidr_block_allow_list or [])})
        for v in allp(c["kv"].list_vaults, cid).data:
            if v.lifecycle_state == "ACTIVE":
                inv["vaults"].append({"name": v.display_name})
    budgets = allp(c["bu"].list_budgets, tenancy, target_type="ALL").data
    inv["budgets"] = [b.display_name for b in budgets
                      if b.target_type == "COMPARTMENT" and set(b.targets or []) & (scope | {tenancy})]
    try:
        inv["cloud_guard"] = c["cg"].get_configuration(tenancy).data.status
    except Exception:  # noqa: BLE001 — not authorised or not available in region
        inv["cloud_guard"] = None
    return inv


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--compartment", help="compartment name or OCID to check (with its sub-compartments)")
    ap.add_argument("--json", action="store_true", help="print findings as JSON")
    args = ap.parse_args()
    findings = check(gather(args.compartment))
    if args.json:
        print(json.dumps(findings, indent=2))
    else:
        print(f"{'SEV':5} {'AREA':12} {'ITEM':38} FINDING")
        for f in findings:
            print(f"{f['severity']:5} {f['area']:12} {f['item'][:38]:38} {f['finding']}")
        counts = {s: sum(f["severity"] == s for f in findings) for s in ("FAIL", "WARN", "INFO")}
        print(f"\n{counts['FAIL']} FAIL, {counts['WARN']} WARN, {counts['INFO']} INFO")
    sys.exit(1 if any(f["severity"] == "FAIL" for f in findings) else 0)


if __name__ == "__main__":
    main()

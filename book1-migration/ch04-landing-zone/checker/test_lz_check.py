"""Offline tests for the lz_check rules: run with  python3 -m pytest -q"""
from lz_check import check

ROOT = "ocid1.tenancy.oc1..root"


def inv(**kw):
    base = {k: [] for k in ("instances", "vcns", "subnets", "security_lists", "nsgs", "nsg_rules",
                            "service_gateways", "buckets", "adbs", "bastions", "vaults", "budgets")}
    base.update(tenancy_id=ROOT, cloud_guard="ENABLED")
    base.update(kw)
    return base


def sev(findings, s):
    return [f for f in findings if f["severity"] == s]


def test_clean_landing_zone_passes():
    f = check(inv(vcns=[{"id": "v1", "name": "lz-vcn", "compartment_id": "net"}],
                  subnets=[{"name": "lz-db-subnet", "private": True}],
                  nsgs=[{"id": "n1", "name": "lz-nsg-db", "vcn_id": "v1"}],
                  service_gateways=[{"vcn_id": "v1"}],
                  bastions=[{"name": "lzbastion", "allow_list": ["203.0.113.10/32"]}],
                  vaults=[{"name": "lz-vault"}], budgets=["lz-budget"]))
    assert [x["severity"] for x in f] == ["PASS"]


def test_hand_built_tenancy_is_flagged():
    f = check(inv(
        instances=[{"name": "render-a1", "compartment_id": ROOT}],
        vcns=[{"id": "v1", "name": "app-vcn", "compartment_id": "c1"},
              {"id": "v2", "name": "app-vcn", "compartment_id": "c1"}],
        subnets=[{"name": "public-subnet", "private": False}, {"name": "db-subnet", "private": False}],
        security_lists=[{"name": "Default Security List", "ingress": [
            {"source": "0.0.0.0/0", "protocol": "6", "tcp": {"min": 22, "max": 22}}]}],
        buckets=[{"name": "dumps", "public_access_type": "ObjectRead"}],
        adbs=[{"name": "appdb", "compartment_id": "c1", "private_endpoint": False, "acl": []}],
    ))
    fails = {(x["item"], x["finding"].split(" —")[0]) for x in sev(f, "FAIL")}
    assert ("db-subnet", "public subnet (public IPs allowed)") in fails
    assert any("SSH (22)" in x["finding"] for x in sev(f, "FAIL"))
    assert any(x["item"] == "dumps" for x in sev(f, "FAIL"))
    warns = " | ".join(x["finding"] for x in sev(f, "WARN"))
    for text in ("root compartment", "2 VCNs share this name", "no network security groups",
                 "no Service Gateway", "accepts connections from any IP", "no Vault", "no budget"):
        assert text in warns, text


def test_port_ranges_and_all_protocols():
    f = check(inv(nsg_rules=[
        {"nsg": "wide", "direction": "INGRESS", "source": "0.0.0.0/0", "protocol": "6", "tcp": {"min": 1500, "max": 1600}},
        {"nsg": "any", "direction": "INGRESS", "source": "0.0.0.0/0", "protocol": "all", "tcp": None},
        {"nsg": "ok", "direction": "INGRESS", "source": "10.0.0.0/16", "protocol": "6", "tcp": {"min": 1521, "max": 1521}},
        {"nsg": "egress", "direction": "EGRESS", "source": None, "protocol": "all", "tcp": None}]))
    items = [x["item"] for x in sev(f, "FAIL")]
    assert items.count("wide") == 2          # 1521 and 1522 inside 1500-1600
    assert items.count("any") == len({22, 1521, 1522, 2484, 3389})
    assert "ok" not in items and "egress" not in items


def test_bastion_open_to_world_is_warned():
    f = check(inv(bastions=[{"name": "b", "allow_list": ["0.0.0.0/0"]}], vaults=[{"name": "v"}], budgets=["x"]))
    assert any(x["item"] == "b" and x["severity"] == "WARN" for x in f)

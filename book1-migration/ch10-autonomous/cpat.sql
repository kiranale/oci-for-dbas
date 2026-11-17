-- Run in SQLcl connected to the SOURCE as a user with SELECT ANY DICTIONARY.
-- -targettype: ATPS (Transaction Processing) or ADWS (Lakehouse) for Autonomous Serverless.
migrateadvisor advise -targettype ATPS -schemas PORTAL -migrationmethod DATAPUMP,GOLDENGATE -reportformat HTML,TEXT -outfileprefix portal

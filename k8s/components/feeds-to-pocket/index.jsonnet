local cron = import 'cronjob.libsonnet';
local ns = import 'ns.libsonnet';
local pvc = import 'pvc.libsonnet';
local sa = import 'sa.libsonnet';

[
  ns,
  sa,
  cron,
] + pvc

local ca = import 'ca.libsonnet';
local cron = import 'cronjob.libsonnet';
local ns = import 'ns.libsonnet';
local pvc = import 'pvc.libsonnet';
local sa = import 'sa.libsonnet';

[
  ca,
  ns,
  sa,
  cron,
] + pvc

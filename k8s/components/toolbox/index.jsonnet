local ca = import './ca.libsonnet';
local ns = import './ns.libsonnet';
local rbac = import './rbac.libsonnet';
local rotateCron = import './rotate-cron.libsonnet';
local sa = import './sa.libsonnet';

[
  ca,
  ns,
  sa,
  rotateCron,
] + rbac

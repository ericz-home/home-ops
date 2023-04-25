local ca = import 'ca.libsonnet';
local deploy = import 'deploy.libsonnet';
local ns = import 'ns.libsonnet';
local rbac = import 'rbac.libsonnet';
local sa = import 'sa.libsonnet';

[
  ns,
  sa,
  ca,
  deploy,
] + rbac

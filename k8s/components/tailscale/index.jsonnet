local coredns = import 'coredns.libsonnet';
local gw = import 'lab-gw.libsonnet';
local ns = import 'ns.libsonnet';
local operator = import 'operator.libsonnet';
local rbac = import 'rbac.libsonnet';
local sa = import 'sa.libsonnet';

[
  ns,
  sa,
] + rbac + coredns + operator

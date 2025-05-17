local cm = import 'configmap.libsonnet';
local deploy = import 'deploy.libsonnet';
local ns = import 'ns.libsonnet';
local pv = import 'pv.libsonnet';
local rbac = import 'rbac.libsonnet';

[ns, deploy, cm] + pv + rbac

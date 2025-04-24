local deploy = import 'deploy.libsonnet';
local http = import 'http.libsonnet';
local ns = import 'ns.libsonnet';
local pv = import 'pv.libsonnet';

[ns] + pv + deploy

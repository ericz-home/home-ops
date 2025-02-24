local deploy = import 'deploy.libsonnet';
local http = import 'http.libsonnet';
local ns = import 'ns.libsonnet';
local pvc = import 'pvc.libsonnet';

[ns, http] + pvc + deploy

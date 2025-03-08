local helm = import 'helm.libsonnet';
local http = import 'http.libsonnet';
local ns = import 'ns.libsonnet';
local pv = import 'pv.libsonnet';

[ns] + http + pv + helm.render()

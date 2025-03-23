local helm = import 'helm.libsonnet';
local http = import 'http.libsonnet';
local ns = import 'ns.libsonnet';
local pv = import 'pv.libsonnet';
local splunk = import 'splunk.libsonnet';

[ns] + pv + helm + [splunk] + http

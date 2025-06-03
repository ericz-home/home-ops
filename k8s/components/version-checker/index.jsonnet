local helm = import 'helm.libsonnet';
local ns = import 'ns.libsonnet';
local prom2json = import 'prom2json.libsonnet';

[ns, prom2json] + helm

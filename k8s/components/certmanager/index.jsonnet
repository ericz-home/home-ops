local bundle = import 'bundle.libsonnet';
local cert = import 'certmanager.libsonnet';
local issuers = import 'clusterissuers.libsonnet';
local ns = import 'ns.libsonnet';
local trust = import 'trustmanager.libsonnet';


[ns, bundle] + cert + trust + issuers

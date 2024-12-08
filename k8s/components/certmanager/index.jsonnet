local cert = import 'certmanager.libsonnet';
local ns = import 'ns.libsonnet';
local trust = import 'trustmanager.libsonnet';


[ns] + cert + trust

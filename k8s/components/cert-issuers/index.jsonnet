local bundle = import 'bundle.libsonnet';
local ns = import 'ns.libsonnet';
local vault = import 'vault.libsonnet';

[ns, bundle] + vault

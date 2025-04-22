local deploy = import 'deploy.libsonnet';
local ns = import 'ns.libsonnet';
local sa = import 'sa.libsonnet';

[ns, sa] + deploy

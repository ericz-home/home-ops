local certs = import 'certificates.libsonnet';
local config = import 'config.libsonnet';
local deploy = import 'deploy.libsonnet';
local ns = import 'ns.libsonnet';
local pv = import 'pv.libsonnet';

[ns] + certs + config + pv + deploy

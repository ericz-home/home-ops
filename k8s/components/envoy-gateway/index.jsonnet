local certs = import 'certificates.libsonnet';
local eg = import 'envoy-gateway.libsonnet';
local gc = import 'gateway-class.libsonnet';
local gw = import 'gateway.libsonnet';
local ns = import 'ns.libsonnet';

[ns] + certs + eg + gw + gc

local ns = import 'ns.libsonnet';
local pv = import 'pv.libsonnet';

local helm = import 'helm.libsonnet';

[
  pv,
  ns,
] + helm

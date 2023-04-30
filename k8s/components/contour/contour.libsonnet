local tailscale = import './tailscale.libsonnet';
local contourYAML = importstr './include/contour.yaml';

local objs = std.parseYaml(contourYAML);

[
  if x.kind == 'DaemonSet' && x.metadata.name == 'envoy' then x {
    spec+: {
      template+: tailscale.proxy,
    },
  } else x
  for x in objs
  if x != null
] + tailscale.rbac

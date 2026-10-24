local helm = importstr 'data://expand-helm/?chart=oci://docker.io/envoyproxy/gateway-helm&name=envoy-gateway&ns=envoy-gateway&version=v1.9.2';

local objs = std.parseYaml(helm);
local ko = [x for x in std.parseYaml(helm) if (!std.isNull(x) && 'apiVersion' in x)];

ko

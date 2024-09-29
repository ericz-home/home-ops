local helm = importstr 'data://expand-helm/?chart=oci://docker.io/envoyproxy/gateway-helm&name=envoy-gateway&ns=envoy-gateway&version=v0.0.0-latest';

local objs = std.parseYaml(helm);

objs

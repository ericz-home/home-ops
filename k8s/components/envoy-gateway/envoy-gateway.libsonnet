local helm = importstr 'data://expand-helm/?chart=oci://docker.io/envoyproxy/gateway-helm&name=envoy-gateway&ns=envoy-gateway&version=v1.2.3';

local objs = std.parseYaml(helm);

objs

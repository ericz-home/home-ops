local helm = importstr 'data://expand-helm/?chart=oci://docker.io/envoyproxy/gateway-helm&name=envoy-gateway&ns=envoy-gateway&version=v1.6.1';

local objs = std.parseYaml(helm);

objs

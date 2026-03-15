local helm = importstr 'data://expand-helm/components/nvidia/include/helm.yaml?chart=nvdp/nvidia-device-plugin&name=nvidia-device-plugin&ns=nvidia';

local objs = std.parseYaml(helm);

objs

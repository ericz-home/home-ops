local helm = importstr 'data://expand-helm/components/zigbee2mqtt/include/helm.yaml?chart=zigbee2mqtt/zigbee2mqtt&name=zigbee2mqtt&ns=zigbee2mqtt';

local objs = std.parseYaml(helm);

objs

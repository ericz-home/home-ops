local conf = importstr './include/mosquitto.conf';
local acls = importstr './include/aclfile';

local cm = {
  apiVersion: 'v1',
  kind: 'ConfigMap',
  metadata: {
    name: 'mqtt',
    namespace: 'mqtt',
  },
  data: {
    'mosquitto.conf': conf,
    aclfile: acls,
  },
};

[cm]

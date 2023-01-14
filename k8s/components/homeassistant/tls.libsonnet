local tls = import 'data://import-tls/pki/certificates/homeassistant';

local secret = {
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: 'homeassistant-tls',
    namespace: 'homeassistant',
  },
  data: {
    'tls.crt': std.base64(tls.crt),
    'tls.key': std.base64(tls.key),
  },
  type: 'kubernetes.io/tls',
};

[secret]

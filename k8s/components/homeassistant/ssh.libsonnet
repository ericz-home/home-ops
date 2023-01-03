local ssh = import 'data://import-ssh/pki/ssh/homeassistant';

local secret = {
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: 'ssh-key-git',
  },
  data: {
    'ssh-privatekey': std.base64(ssh.privateKey + '\n'),
    'ssh-publickey': std.base64(ssh.publicKey + '\n'),
    known_hosts: std.base64(ssh.knownHosts + '\n'),
  },
  type: 'kubernetes.io/ssh-auth',
};

[secret]

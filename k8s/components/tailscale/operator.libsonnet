local helm = importstr 'data://expand-helm/?chart=tailscale/tailscale-operator&name=tailscale-operator&ns=tailscale';

local objs = std.parseYaml(helm);

local vault_annotations =
  {
    'vault.hashicorp.com/tls-secret': 'lab-ca',
    'vault.hashicorp.com/ca-cert': '/vault/tls/ca.crt',
    'vault.hashicorp.com/role': 'tailscale-secrets-role',
    'vault.hashicorp.com/agent-inject': 'true',
    'vault.hashicorp.com/agent-pre-populate-only': 'true',
    'vault.hashicorp.com/agent-run-as-user': '1000',
  } +
  // add tailscale operator oauth client values
  // use {{- end -}} to suppress trailing linefeed
  {
    'vault.hashicorp.com/agent-inject-secret-client_id': 'secrets/tailscale/operator',
    'vault.hashicorp.com/secret-volume-path-client_id': '/oauth/',
    'vault.hashicorp.com/agent-inject-template-client_id': |||
      {{ with secret "secrets/tailscale/operator" -}}
      {{ .Data.data.client_id }}
      {{- end -}}
    |||,
  } +
  {
    'vault.hashicorp.com/agent-inject-secret-client_secret': 'secrets/tailscale/operator',
    'vault.hashicorp.com/secret-volume-path-client_secret': '/oauth/',
    'vault.hashicorp.com/agent-inject-template-client_secret': |||
      {{ with secret "secrets/tailscale/operator" -}}
      {{ .Data.data.client_secret }}
      {{- end -}}
    |||,
  };


[
  if x.kind == 'Deployment' && x.metadata.name == 'operator' then x {
    spec+: {
      template+: {
        metadata+: {
          annotations+: vault_annotations,
        },
        spec+: {
          volumes: [
            v
            for v in x.spec.template.spec.volumes
            if v.name != 'oauth'
          ],
          containers: [
            if c.name == 'operator' then c {
              volumeMounts: [
                m
                for m in c.volumeMounts
                if m.name != 'oauth'
              ],
            } else c
            for c in x.spec.template.spec.containers
          ],
        },
      },
    },
  } else if x.kind != 'IngressClass' then x
  for x in objs
  if x != null
]

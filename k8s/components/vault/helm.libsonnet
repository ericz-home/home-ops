local helm = importstr 'data://expand-helm/components/vault/include/helm.yaml?chart=hashicorp/vault&name=vault&ns=vault';

local objs = std.parseYaml(helm);

[
  if x.kind != 'StatefulSet' then x else x {
    spec+: {
      volumeClaimTemplates: [
        x.spec.volumeClaimTemplates[0] {
          spec+: {
            selector: {
              matchLabels: {
                app: 'vault',
              },
            },
          },
        },
      ],
    },
  }
  for x in objs
]

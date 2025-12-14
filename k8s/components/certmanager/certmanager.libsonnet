local helm = importstr 'data://expand-helm/components/certmanager/include/certmanager.yaml?chart=jetstack/cert-manager&name=certmanager&ns=certmanager';

local objs = std.parseYaml(helm);

[
  if std.endsWith(x.metadata.name, 'startupapicheck') then
    x {
      spec+: {
        ttlSecondsAfterFinished: 900,
      },
    }
  else x
  for x in objs
]

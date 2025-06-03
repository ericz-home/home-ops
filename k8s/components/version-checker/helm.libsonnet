local helm = importstr 'data://expand-helm/components/version-checker/include/helm.yaml?chart=jetstack/version-checker&name=version-checker&ns=version-checker';

local objs = std.parseYaml(helm);

[o { metadata+: { namespace: 'version-checker' } } for o in objs]

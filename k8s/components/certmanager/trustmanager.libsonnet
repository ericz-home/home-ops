local helm = importstr 'data://expand-helm/components/certmanager/include/trustmanager.yaml?chart=jetstack/trust-manager&name=trustmanager&ns=certmanager';

local objs = std.parseYaml(helm);

objs

local helm = importstr 'data://expand-helm/components/certmanager/include/certmanager.yaml?chart=jetstack/cert-manager&name=certmanager&ns=certmanager';

std.parseYaml(helm)

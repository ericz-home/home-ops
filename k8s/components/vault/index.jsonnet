local certs = import 'certificates.libsonnet';
local helm = import 'helm.libsonnet';
local http = import 'http.libsonnet';
local ns = import 'ns.libsonnet';
local pv = import 'pv.libsonnet';


function(bootstrap='false')
  [
    pv,
    ns,
  ] + http + helm.render(bootstrap == 'true') + certs

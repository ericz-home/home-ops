local certs = import 'certificates.libsonnet';
local esphome = import 'esphome.libsonnet';
local deploy = import 'homeassistant.libsonnet';
local ingress = import 'ingress.libsonnet';
local ns = import 'ns.libsonnet';
local pvc = import 'pvc.libsonnet';
local sa = import 'sa.libsonnet';


local merge(arr, o) =
  arr + (
    if std.isArray(o) then
      o
    else
      [o]
  );


std.foldl(merge, [
  ns,
  sa,
  deploy,
  esphome,
  ingress,
  pvc,
  certs,
], [])

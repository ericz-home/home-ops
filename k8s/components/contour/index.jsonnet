local certs = import './certificates.libsonnet';
local contour = import './contour.libsonnet';

contour + certs

local operator = importstr 'data://expand-helm/components/splunk/include/operator.yaml?chart=splunk/splunk-operator&name=splunk-operator&ns=splunk';
local otel = importstr 'data://expand-helm/components/splunk/include/otel.yaml?chart=splunk-otel-collector-chart/splunk-otel-collector&name=splunk-otel-collector&ns=splunk';

local operatorObjs = std.parseYaml(operator);

local otelObjs = std.parseYaml(otel);

[
  o {
    metadata+: {
      namespace: 'splunk',
    },
  }
  for o in operatorObjs
]
+
[
  if o.metadata.name == 'splunk-otel-collector-agent' && o.kind == 'DaemonSet' then o {
    spec+: {
      template+: {
        spec+: {
          containers: [
            if c.name == 'otel-collector' then c {
              volumeMounts: [
                if v.name == 'varlog' then v {
                  mountPath: '/var/log/pods',
                }
                else v
                for v in c.volumeMounts
              ],
            }
            else c
            for c in o.spec.template.spec.containers
          ],
          volumes: [
            if v.name == 'varlog' then v {
              hostPath: {
                path: '/home/home/.rancher/k3s/logs/pods',
              },
            } else v
            for v in o.spec.template.spec.volumes
          ],
        },
      },
    },
  }
  else o
  for o in otelObjs
]

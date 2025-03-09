local helm = importstr 'data://expand-helm/components/open-webui/include/helm.yaml?chart=open-webui/open-webui&name=open-webui&ns=open-webui';

local objs = std.parseYaml(helm);

local render = function()
  [
    if x.kind == 'StatefulSet' then x {
      spec+: {
        template+: {
          spec+: {
            containers: [
              if c.name == 'open-webui' then c {
                command: ['bash', '-c'],
                args: ['update-ca-certificates && source /vault/secrets/oidc && source /vault/secrets/openai && bash start.sh'],
              }
              for c in x.spec.template.spec.containers
            ],
          },
        },
      },
    } else x
    for x in objs
  ];

{
  render:: render,
}

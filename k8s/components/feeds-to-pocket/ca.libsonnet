local caOld = importstr 'data://get-ca/out/Lab_Root.crt';
local caNew = importstr 'data://get-ca/out/Lab_Root_2029.crt';
local ca = std.base64(caOld + caNew);

{
  apiVersion: 'v1',
  kind: 'Secret',
  metadata: {
    name: 'lab-ca',
    namespace: 'feeds-to-pocket',
  },
  type: 'Opaque',
  data: {
    'ca.crt': ca,
  },
}

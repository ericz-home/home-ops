HomeAssistant MQTT Auth requires uploading certificates via the UI only. When expired, this will require re-uploading the cert-manager managed certificates. 

Download the mqtt-auth k8s secret as json. Parse out the individual secret fields to PEM encoded files. Upload the files in HA UI.

kubectl -n homeassistant get secret mqtt-auth -o json > mqtt.json
cat mqtt.json | jq -r '.data["ca.crt"]' | base64 -d > ca.crt 
cat mqtt.json | jq -r '.data["tls.key"]' | base64 -d > tls.key
cat mqtt.json | jq -r '.data["tls.crt"]' | base64 -d > tls.crt

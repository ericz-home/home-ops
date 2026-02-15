HomeAssistant MQTT Auth requires uploading certificates via the UI only. When expired, this will require re-uploading the cert-manager managed certificates. 

Download the mqtt-auth k8s secret as json. Parse out the individual secret fields to PEM encoded files. Upload the files in HA UI.

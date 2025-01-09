#!/bin/bash
set -m
until [ \
    "$(curl -s -w '%{http_code}' -o /dev/null "${CODER_URL}/api/v2/buildinfo")" \
    -eq 200 ]
do
    echo "waiting for coder to be ready"
    sleep 5
done
coder login --use-token-as-session
{{- range .Values.coder.template.customTemplates }}
echo "Upgrading {{ .name }} template"
mkdir /home/coder/{{ .name }}/
cp /home/coder/custom-template/{{ .name }}-main.tf /home/coder/{{ .name }}/main.tf
coder templates push --activate -d /home/coder/{{ .name }} {{ .name }} --variable minio_endpoint={{ $.Values.global.minio.endpoint }}:{{ $.Values.global.minio.endpointPort }},minio_bucket={{ $.Values.global.minio.bucket }},namespace={{ $.Release.Namespace }},service_type={{ $.Values.global.service.type }},node_port={{ .nodePort }},image={{ .image }},external_url={{ default $.Values.global.externalHostAddress $.Subcharts.coder.Values.externalHostAddress }},https={{ include "platform.coderIngressTlsEnabled" $ }}{{ if eq .name "dremio"}},minio_platform_user_secret={{ $.Values.global.minio.platformUserSecret }}{{ end }}{{ if eq .name "jupyter"}},image_3_9={{ .image39 }},image_3_11={{ .image311 }},privileged={{ .privileged }}{{ if $.Values.core.ingress.enabled }}{{ with (index $.Values.core.ingress.hosts 0) }},dhcore_endpoint=https://{{ .host }},dhcore_issuer=https://{{ .host }}{{end}}{{else}},dhcore_endpoint="",dhcore_issuer=""{{ end }}{{ end }} -y 
coder template edit --icon "{{ .iconUrl }}" {{ .name }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "platform.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "platform.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "platform.labels" -}}
helm.sh/chart: {{ include "platform.chart" . }}
{{ include "platform.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "platform.selectorLabels" -}}
app.kubernetes.io/name: {{ include "platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "platform.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "platform.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create registry auth values 
*/}}
{{- define "platform.registryAuth" -}}
{{- if and .Values.global.registry.username .Values.global.registry.password }}
{{- printf "%s:%s" .Values.global.registry.username .Values.global.registry.password | b64enc }}
{{- end }}
{{- end }}

{{/*
Calculate dashboard oidc configuration endpoint
*/}}
{{- define "platform.oidcDashboardEndpoint" -}}
{{- if .Values.dashboard.ingress.enabled}}
{{- with (index .Values.dashboard.ingress.hosts 0) }}
{{- .host -}}
{{- end }}
{{- else }}
{{- if eq .Values.global.service.type "NodePort"}}
{{ .Values.global.externalHostAddress }}:{{ .Values.dashboard.service.httpNodePort }}
{{- else }}
{{ .Values.global.externalHostAddress }}:{{ .Values.dashboard.service.port }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate coder access url
*/}}
{{- define "platform.coderAccUrl" -}}
{{- $hasAccessURL := false }}
{{- range .Values.coder.coder.env }}
{{- if (eq .name "CODER_ACCESS_URL") }}
{{- $hasAccessURL = true }}
{{- end }}
{{- end }}
{{- if not $hasAccessURL -}}
- name: CODER_ACCESS_URL
  value: "http://coder"
{{ end -}}
{{- end -}}

{{/*
Coder ingress TLS enabled check.
*/}}
{{- define "platform.coderIngressTlsEnabled" -}}
{{- if or .Values.coder.coder.ingress.tls.enable .Values.global.externalTls -}}
true
{{- else -}}
false
{{- end }}
{{- end }}

{{/*
Set packages versions for tests
*/}}
{{- define "platform.testPackages" -}}
{{- $command := "" -}}
{{- if .Values.platformTests.preRelease -}}
{{- $command = "pip install --pre --cache-dir home/pipcache" -}}
{{- else -}}
{{- $command = "pip install --cache-dir home/pipcache" -}}
{{- end -}}
{{- range $package := .Values.platformTests.packages -}}
{{- $command = printf "%s %s" $command $package.name }}
{{- if $package.tag -}}
{{- $command = printf "%s==%s" $command $package.tag }}
{{- end -}}
{{- end }}
{{- $command = printf "%s %s" $command "requests-oauthlib" }}
{{ $command }}
{{- end }}



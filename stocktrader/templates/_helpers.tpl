{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "trader.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "trader.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "external.configMap" -}}
{{- if .Values.global.externalConfigMap -}}
name: {{ .Values.global.configMapName }}
{{- else -}}
name: {{ .Release.Name }}-config
{{- end -}}
{{- end -}}

{{- define "external.secret" -}}
{{- if .Values.global.externalSecret -}}
name: {{ .Values.global.secretName }}
{{- else -}}
name: {{ .Release.Name }}-credentials
{{- end -}}
{{- end -}}
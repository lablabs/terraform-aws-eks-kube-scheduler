{{- define "kube-scheduler.namespace" -}}
{{- .Release.Namespace }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "kube-scheduler.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "kube-scheduler.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "kube-scheduler.fullname" -}}
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
Create the name of the service account
*/}}
{{- define "kube-scheduler.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "kube-scheduler.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Create the name of the config map
*/}}
{{- define "kube-scheduler.configMapName" -}}
{{- if .Values.config.create }}
{{- default (include "kube-scheduler.fullname" .) .Values.config.name }}
{{- else }}
{{- default "default" .Values.config.name }}
{{- end }}
{{- end }}


{{/*
Common labels
*/}}
{{- define "kube-scheduler.labels" -}}
helm.sh/chart: {{ include "kube-scheduler.chart" . }}
{{ include "kube-scheduler.selectorLabels" . }}
{{- if or .Chart.AppVersion .Values.image.tag }}
app.kubernetes.io/version: {{ mustRegexReplaceAllLiteral "@sha.*" .Values.image.tag "" | default .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end }}


{{/*
Selector labels
*/}}
{{- define "kube-scheduler.selectorLabels" -}}
app.kubernetes.io/name: {{ include "kube-scheduler.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

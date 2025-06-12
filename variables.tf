# IMPORTANT: Add addon specific variables here
variable "enabled" {
  type        = bool
  default     = true
  description = "Set to false to prevent the module from creating any resources."
  nullable    = false
}

variable "manifest_target_path" {
  type        = string
  default     = "charts/kube-scheduler"
  description = "Manifest target path in projects repository"
}

variable "name" {
  type = string
  default     = "nginx-ingress"
  description = "Name of the Helm installation"
}

variable "repository" {
  type = string  
  default     = "nginx"
  description = "Helm chart repo name"
}

variable "chart" {
  type = string  
  default     = "nginx"
  description = "helm chart name"
}

variable "serviceType" {
  type        = string
  default     = "ClusterIP"
  description = "Type of the service. Default is ClusterIP"
}

variable "app1" {
  type = string
  default     = "container1"
  description = "Name of the Helm installation"
}


variable "app2" {
  type = string
  default     = "container2"
  description = "Name of the Helm installation"
}


variable "image" {
  type = string  
  default     = "nginx"
  description = "Helm chart repo name"
}

variable "port1" {
  type = string  
  default     = "80"
  description = "helm chart name"
}

variable "port2" {
  type = string  
  default     = "80"
  description = "helm chart name"
}


variable "serviceType" {
  type        = string
  default     = "ClusterIP"
  description = "Type of the service. Default is ClusterIP"
}

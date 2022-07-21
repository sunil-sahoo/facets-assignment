terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}


resource "helm_release" "nginx-ingress-controller" {
  name       = var.name
  repository = var.repository
  chart      = var.chart

 set {
    name  = "service.type"
    value = var.serviceType
  }
}	






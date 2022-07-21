terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.12.0"
    }
  }
}
provider "kubernetes" {
  config_path = "~/.kube/config"
}



locals {
    # get json 
    json_data = jsondecode(file("app.json"))

    applications = jsondecode(file("app.json")).applications


}

resource "kubernetes_deployment" "resource" {
    count = length(local.applications)

  metadata {
    name      = local.applications[count.index].name
    labels = {
      app = local.applications[count.index].name
    }
  }
  spec {
    replicas = local.applications[count.index].replicas
    selector {
      match_labels = {
        app = local.applications[count.index].name
      }
    }
    template {
      metadata {
        labels = {
          app = local.applications[count.index].name
        }
      }
      spec {
        container {
          image = local.applications[count.index].image
          args = [local.applications[count.index].args[0].arg1, local.applications[count.index].args[0].arg2 ]
          name  = local.applications[count.index].name
          port {
            container_port = local.applications[count.index].port
          }
        }
      }
    }
  }
}






resource "kubernetes_service" "service" {
  count = length(local.applications)

  metadata {
    name    = local.applications[count.index].name
    labels = {
          app = local.applications[count.index].name
    }
  }
  spec {
    selector = {
      app = local.applications[count.index].name
    }
    type = "ClusterIP"
    port {
      port        = local.applications[count.index].port
      target_port = local.applications[count.index].port
    }
  }
}




resource "kubernetes_ingress_v1" "main-ingress" {
  count = length(local.applications) - 1 
  metadata {
    name = local.applications[count.index].name
    annotations = {
    "kubernetes.io/ingress.class" : "nginx",
    }
  }

  spec {
    rule {
      host = "test.domain.com"
      http {
        path {
          backend {
            service {
              name = local.applications[count.index].name
              port {
                number = local.applications[count.index].port
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}



resource "kubernetes_ingress_v1" "ingress" {

  metadata {
    name = local.applications[1].name
    annotations = {
    "kubernetes.io/ingress.class" : "nginx",
    "nginx.ingress.kubernetes.io/canary" : "true",
    "nginx.ingress.kubernetes.io/canary-weight" : local.applications[1].traffic_weight
    }
  }

  spec {
    rule {
      host = "test.domain.com"
      http {
        path {
          backend {
            service {
              name = local.applications[1].name
              port {
                number = local.applications[1].port
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}

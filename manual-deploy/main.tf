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


resource "kubernetes_deployment" "blueresource" {
  metadata {
    name      = var.app1
    labels = {
      app = var.app1
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.app1
      }
    }
    template {
      metadata {
        labels = {
          app = var.app1
        }
      }
      spec {
        container {
          image = var.image
          args = ["-listen=:8080", "-text=\"I am blue\""]
          name  = var.app1
          port {
            container_port = var.port1
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "blueservice" {
  metadata {
    name      = var.app1
  }
  spec {
    selector = {
      app = kubernetes_deployment.blueresource.spec.0.template.0.metadata.0.labels.app
    }
    type = "ClusterIP"
    port {
      port        = var.port1
      target_port = var.port1
    }
  }
}


resource "kubernetes_deployment" "greenresource" {
  metadata {
    name      = var.app2
    labels = {
      app = var.app2
    }
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = var.app2
      }
    }
    template {
      metadata {
        labels = {
          app = var.app2
        }
      }
      spec {
        container {
          image = var.image
          args = ["-listen=:8081", "-text=\"I am green\""]
          name  = var.app2
          port {
            container_port = var.port2
          }
        }
      }
    }
  }
}


resource "kubernetes_service" "greenservices" {
  metadata {
    name      = var.app2
  }
  spec {
    selector = {
      app = kubernetes_deployment.greenresource.spec.0.template.0.metadata.0.labels.app
    }
    type = "ClusterIP"
    port {
      port        = var.port2
      target_port = var.port2
    }
  }
}


resource "kubernetes_ingress_v1" "blue-ingress" {
  metadata {
    name = "blue-ingress"
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
              name = var.app1
              port {
                number = var.port1
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}




resource "kubernetes_ingress_v1" "green-ingress" {
  metadata {
    name = "green-ingress"
    annotations = {
    "kubernetes.io/ingress.class" : "nginx",
    "nginx.ingress.kubernetes.io/canary" : "true",
    "nginx.ingress.kubernetes.io/canary-weight" : "25"
    }
  }

  spec {
    rule {
      host = "test.domain.com"
      http {
        path {
          backend {
            service {
              name = var.app2
              port {
                number = var.port2
              }
            }
          }
          path = "/"
        }
      }
    }
  }
}



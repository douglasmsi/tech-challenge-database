provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "demo_app_ns" {
  metadata {
    name = "demo-app-ns"
  }
}
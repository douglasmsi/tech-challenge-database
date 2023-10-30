provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "my-context"
}

resource "kubernetes_namespace" "demo_app_ns" {
  metadata {
    name = "demo-app-ns"
  }
}
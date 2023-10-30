resource "kubernetes_secret" "demo_app_secret" {
  metadata {
    name = "mysql-pass"
    namespace = kubernetes_namespace.demo_app_ns.metadata.0.name
  }

  data = {
    mysql-root-password = "cm9vdHBhc3N3b3Jk"
    mysql-user-password = "dXNlcnBhc3N3b3Jk"
  }
}
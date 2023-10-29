resource "kubernetes_secret" "tech-challenge-database-secret" {
  metadata {
    name = "postgres-pass"
    namespace = kubernetes_namespace.tech-challenge-database-namespace.metadata.0.name
  }

  data = {
    postgres-root-password = "cm9vdHBhc3N3b3Jk"
    postgres-user-password = "dXNlcnBhc3N3b3Jk"
  }
}
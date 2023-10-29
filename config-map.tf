resource "kubernetes_config_map" "tech-challenge-config-map" {
  metadata {
    name = "postgres-config-map"
    namespace = kubernetes_namespace.tech-challenge-database-namespace.metadata.0.name
  }

  data = {
    postgres-server        = "tech-challenge-postgres"
    postgres-database-name = "tech-challenge-database"
    postgres-user-username = "tech-challenge-user"
  }
}
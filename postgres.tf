resource "kubernetes_service" "tech-challenge-app-postgres-service" {
  metadata {
    name      = "tech-challenge-app-postgres"
    namespace = kubernetes_namespace.tech-challenge-database-namespace.metadata.0.name
    labels = {
      app = "tech-challenge-app"
    }
  }

  spec {
    selector = {
      app  = kubernetes_deployment.tech-challenge-app-postgres-deployment.metadata.0.labels.app
      tier = "postgres"
    }

    port {
      port = 5432
    }

    cluster_ip = "None"
  }
}

resource "kubernetes_persistent_volume_claim" "tech-challenge-app-pvc" {
  metadata {
    name      = "postgres-pvc"
    namespace = kubernetes_namespace.tech-challenge-database-namespace.metadata.0.name
    labels = {
      app = "tech-challenge-app"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

resource "kubernetes_deployment" "tech-challenge-app-postgres-deployment" {
  metadata {
    name      = "tech-challenge-app-postgres"
    namespace = kubernetes_namespace.tech-challenge-database-namespace.metadata.0.name
    labels = {
      app = "tech-challenge-app"
    }
  }

  spec {
    selector {
      match_labels = {
        app  = "tech-challenge-app"
        tier = "postgres"
      }
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = {
          app  = "tech-challenge-app"
          tier = "postgres"
        }
      }

      spec {
        container {
          image = "postgres:latest"
          name  = "postgres"

          env {
            name = "POSTGRES_DATABASE"
            value_from {
              config_map_key_ref {
                key  = "postgres-database-name"
                name = kubernetes_config_map.tech-challenge-config-map.metadata.0.name

              }
            }
          }

          env {
            name = "POSTGRES_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "postgres-root-password"
                name = kubernetes_secret.tech-challenge-database-secret.metadata.0.name

              }
            }
          }

          env {
            name = "POSTGRES_USER"
            value_from {
              config_map_key_ref {
                key  = "postgres-user-username"
                name = kubernetes_config_map.tech-challenge-config-map.metadata.0.name

              }
            }
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "postgres-user-password"
                name = kubernetes_secret.tech-challenge-database-secret.metadata.0.name

              }
            }
          }

          liveness_probe {
            tcp_socket {
              port = 5432
            }
          }

          port {
            name           = "postgres"
            container_port = 5432
          }

          volume_mount {
            name       = "postgres-persistent-storage"
            mount_path = "/var/lib/postgres"
          }
        }

        volume {
          name = "postgres-persistent-storage"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.tech-challenge-app-pvc.metadata.0.name
          }
        }
      }
    }
  }
}

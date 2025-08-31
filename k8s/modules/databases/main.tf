resource "kubernetes_stateful_set" "db" {
  for_each = var.databases

  metadata {
    name = each.key
    namespace = var.namespace
  }

  spec {
    service_name = "${each.key}-svc"
    replicas     = 1
    selector { match_labels = { app = each.key } }

    template {
      metadata {
        labels = { app = each.key }
      }
      spec {
        container {
          name  = each.key
          image = var.postgres_image
          port { container_port = 5432 }

          env {
            name  = "POSTGRES_DB"
            value = var.postgres_db_name
          }
          env {
            name  = "POSTGRES_USER"
            value = var.postgres_user
          }
          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = var.postgres_secret_name
                key  = "POSTGRES_PASSWORD"
              }
            }
          }
          volume_mount {
            name       = "${each.key}-data"
            mount_path = "/var/lib/postgresql/data"
          }
        }
      }
    }

    volume_claim_template {
      metadata { name = "${each.key}-data" }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources {
          requests = { storage = each.value.storage }
        }
      }
    }
  }
}

resource "kubernetes_service" "db_svc" {
  for_each = var.databases

  metadata {
    name      = "${each.key}-svc"
    namespace = var.namespace
  }

  spec {
    selector = { app = each.key }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}

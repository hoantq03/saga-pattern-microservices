# # --- Prometheus ---
# resource "kubernetes_config_map" "prometheus_config" {
#   metadata { 
#     name = "prometheus-config-cm"
#     namespace = var.namespace
#   }
#   data = {
#     "prometheus.yml" = yamlencode({
#       global = {
#         scrape_interval = "15s"
#       }
#       scrape_configs = [
#         {
#           job_name        = "prometheus"
#           static_configs  = [{ targets = [var.prometheus_service_target] }]
#         },
#         {
#           job_name        = "kafka-exporter"
#           static_configs  = [{ targets = [var.kafka_exporter_target] }]
#         },
#         {
#           job_name        = "postgres-exporter"
#           static_configs  = [{ targets = [var.postgres_exporter_target] }]
#         }
#       ]
#     })
#   }
# }

# resource "kubernetes_deployment" "prometheus" {
#   metadata {
#     name      = "prometheus"
#     namespace = var.namespace
#   }
#   spec {
#     replicas = 1
#     selector { match_labels = { app = "prometheus" } }
#     template {
#       metadata { labels = { app = "prometheus" } }
#       spec {
#         container {
#           name  = "prometheus"
#           image = "prom/prometheus:v2.45.0"
#           port { container_port = 9090 }
#           args = ["--config.file=/etc/prometheus/prometheus.yml"]
#           volume_mount {
#             name       = "prometheus-config-volume"
#             mount_path = "/etc/prometheus/"
#           }
#         }
#         volume {
#           name = "prometheus-config-volume"
#           config_map {
#             name = kubernetes_config_map.prometheus_config.metadata[0].name
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "prometheus_svc" {
#   metadata {
#     name      = "prometheus-svc"
#     namespace = var.namespace
#   }
#   spec {
#     selector = { app = "prometheus" }
#     port {
#       port       = 9090
#       target_port = 9090
#     }
#     type     = "LoadBalancer"
#   }
# }

# # --- Grafana ---
# resource "kubernetes_deployment" "grafana" {
#   metadata {
#     name      = "grafana"
#     namespace = var.namespace
#   }
#   spec {
#     replicas = 1
#     selector { match_labels = { app = "grafana" } }
#     template {
#       metadata { labels = { app = "grafana" } }
#       spec {
#         container {
#           name  = "grafana"
#           image = "grafana/grafana:9.5.1"
#           port { container_port = 3000 }
#           env {
#             name  = "GF_SECURITY_ADMIN_USER"
#             value = "admin"
#           }
#           env {
#             name  = "GF_SECURITY_ADMIN_PASSWORD"
#             value = "admin"
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "grafana_svc" {
#   metadata {
#     name      = "grafana-svc"
#     namespace = var.namespace
#   }
#   spec {
#     selector = { app = "grafana" }
#     port {
#       port       = 3000
#       target_port = 3000
#     }
#     type     = "LoadBalancer"
#   }
# }

# # --- Kafka Exporter ---
# resource "kubernetes_deployment" "kafka_exporter" {
#   metadata {
#     name      = "kafka-exporter"
#     namespace = var.namespace
#   }
#   spec {
#     replicas = 1
#     selector { match_labels = { app = "kafka-exporter" } }
#     template {
#       metadata { labels = { app = "kafka-exporter" } }
#       spec {
#         container {
#           name  = "kafka-exporter"
#           image = "danielqsj/kafka-exporter:v1.7.0"
#           port { container_port = 9308 }
#           args = ["--kafka.server=${var.kafka_server_target}"]
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "kafka_exporter_svc" {
#   metadata {
#     name      = "kafka-exporter-svc"
#     namespace = var.namespace
#   }
#   spec {
#     selector = { app = "kafka-exporter" }
#     port {
#       port       = 9308
#       target_port = 9308
#     }
#   }
# }

# # --- Postgres Exporter ---
# resource "kubernetes_deployment" "postgres_exporter" {
#   metadata {
#     name      = "postgres-exporter"
#     namespace = var.namespace
#   }
#   spec {
#     replicas = 1
#     selector { match_labels = { app = "postgres-exporter" } }
#     template {
#       metadata { labels = { app = "postgres-exporter" } }
#       spec {
#         container {
#           name  = "postgres-exporter"
#           image = "quay.io/prometheuscommunity/postgres-exporter"
#           port { container_port = 9187 }
#           env {
#             name  = "DATA_SOURCE_NAME"
#             value = var.postgres_exporter_dsn
#           }
#         }
#       }
#     }
#   }
# }

# resource "kubernetes_service" "postgres_exporter_svc" {
#   metadata {
#     name      = "postgres-exporter-svc"
#     namespace = var.namespace
#   }
#   spec {
#     selector = { app = "postgres-exporter" }
#     port {
#       port       = 9187
#       target_port = 9187
#     }
#   }
# }

# # --- Elasticsearch ---
# resource "kubernetes_stateful_set" "elasticsearch" {
#   metadata { 
#     name = "elasticsearch"
#     namespace = var.namespace
#   }
#   spec {
#     service_name = "elasticsearch-svc"
#     replicas     = 1
#     selector { match_labels = { app = "elasticsearch" } }
#     template {
#       metadata { labels = { app = "elasticsearch" } }
#       spec {
#         container {
#           name  = "elasticsearch"
#           image = "docker.elastic.co/elasticsearch/elasticsearch:8.7.1"
#           port { container_port = 9200 }
#           env { 
#             name = "discovery.type"
#             value = "single-node"
#           }
#           env { 
#             name = "xpack.security.enabled"
#             value = "false"
#           }
#           env { 
#             name = "ES_JAVA_OPTS"
#             value = "-Xms1g -Xmx1g"
#           }
#           volume_mount {
#             name       = "esdata"
#             mount_path = "/usr/share/elasticsearch/data"
#           }
#         }
#       }
#     }
#     volume_claim_template {
#       metadata { name = "esdata" }
#       spec {
#         access_modes = ["ReadWriteOnce"]
#         resources { requests = { storage = "10Gi" } }
#       }
#     }
#   }
# }
# resource "kubernetes_service" "elasticsearch_svc" {
#   metadata {
#     name      = "elasticsearch-svc"
#     namespace = var.namespace
#   }
#   spec {
#     selector = { app = "elasticsearch" }
#     port {
#       port        = 9200
#       target_port = 9200
#     }
#   }
# }

# # --- Kibana ---
# resource "kubernetes_deployment" "kibana" {
#   metadata {
#     name      = "kibana"
#     namespace = var.namespace
#   }
#   spec {
#     replicas = 1
#     selector { match_labels = { app = "kibana" } }
#     template {
#       metadata { labels = { app = "kibana" } }
#       spec {
#         container {
#           name  = "kibana"
#           image = "docker.elastic.co/kibana/kibana:8.7.1"
#           port { container_port = 5601 }
#           env {
#             name  = "ELASTICSEARCH_HOSTS"
#             value = "http://elasticsearch-svc:9200"
#           }
#         }
#       }
#     }
#   }
# }
# resource "kubernetes_service" "kibana_svc" {
#   metadata {
#     name      = "kibana-svc"
#     namespace = var.namespace
#   }
#   spec {
#     selector = { app = "kibana" }
#     port {
#       port        = 5601
#       target_port = 5601
#     }
#     type     = "LoadBalancer"
#   }
# }

# # --- Logstash ---
# resource "kubernetes_config_map" "logstash_pipeline" {
#   metadata {
#     name      = "logstash-pipeline-cm"
#     namespace = var.namespace
#   }
#   data = {
#     "logstash.conf" = <<-EOT
#       input {
#         gelf {
#           port => 12201
#           type => "gelf"
#         }
#       }
#       output {
#         elasticsearch {
#           hosts => ["http://elasticsearch-svc:9200"]
#           index => "logstash-%%{+YYYY.MM.dd}"
#         }
#       }
#     EOT
#   }
# }
# resource "kubernetes_deployment" "logstash" {
#   metadata {
#     name      = "logstash"
#     namespace = var.namespace
#   }
#   spec {
#     replicas = 1
#     selector { match_labels = { app = "logstash" } }
#     template {
#       metadata { labels = { app = "logstash" } }
#       spec {
#         container {
#           name  = "logstash"
#           image = "docker.elastic.co/logstash/logstash:8.7.1"
#           port {
#             container_port = 12201
#             protocol = "UDP"
#           }
#           volume_mount {
#             name       = "logstash-pipeline-volume"
#             mount_path = "/usr/share/logstash/pipeline/logstash.conf"
#             sub_path   = "logstash.conf"
#           }
#         }
#         volume {
#           name = "logstash-pipeline-volume"
#           config_map {
#             name = kubernetes_config_map.logstash_pipeline.metadata[0].name
#           }
#         }
#       }
#     }
#   }
# }
# resource "kubernetes_service" "logstash_svc" {
#   metadata {
#     name      = "logstash-svc"
#     namespace = var.namespace
#   }
#   spec {
#     selector = { app = "logstash" }
#     port { 
#       name = "gelf-udp"
#       port = 12201
#       target_port = 12201
#       protocol = "UDP"
#     }
#     type     = "LoadBalancer"
#   }
# }

# variable "postgres_exporter_dsn" {
#   description = "The DSN for the Postgres Exporter."
#   type        = string
# }

# variable "kafka_server_target" {
#   description = "The target for the Kafka Exporter."
#   type        = string
# }

# variable "prometheus_service_target" {
#   description = "The target for Prometheus to scrape itself, using the Kubernetes service name."
#   type        = string
#   default     = "prometheus-svc:9090" 
# }


# variable "kafka_exporter_target" {
#   description = "The scrape target for the Kafka Exporter service."
#   type        = string
# }

# variable "postgres_exporter_target" {
#   description = "The scrape target for the Postgres Exporter service."
#   type        = string
# }

# variable "namespace" { 
#   description = "The Kubernetes namespace to deploy the database services into."
#   type        = string
# }

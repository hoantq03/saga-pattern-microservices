# output "grafana_endpoint" {
#   description = "The endpoint for the Grafana service."
#   value       = kubernetes_service.grafana_svc.status.0.load_balancer.0.ingress.0.hostname
# }

# output "prometheus_endpoint" {
#   description = "The endpoint for the Prometheus service."
#   value       = kubernetes_service.prometheus_svc.status.0.load_balancer.0.ingress.0.hostname
# }

# output "kafka_exporter_service_target" {
#   description = "The FQDN and port for the Kafka exporter service."
#   value       = "${kubernetes_service.kafka_exporter_svc.metadata[0].name}:9308"
# }

# output "postgres_exporter_service_target" {
#   description = "The FQDN and port for the Postgres exporter service."
#   value       = "${kubernetes_service.postgres_exporter_svc.metadata[0].name}:9187"
# }

# output "prometheus_service_target" {
#   description = "The FQDN and port for the Prometheus service."
#   value       = "${kubernetes_service.prometheus_svc.metadata[0].name}:9090"
# }

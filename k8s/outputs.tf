# output "grafana_endpoint" {
#   description = "Grafana service endpoint."
#   value       = module.monitoring.grafana_endpoint
# }

# output "kibana_endpoint" {
#   description = "Kibana service endpoint."
#   value       = module.logging.kibana_endpoint
# }

# output "prometheus_endpoint" {
#   description = "Prometheus service endpoint."
#   value       = module.monitoring.prometheus_endpoint
# }

output "control_center_endpoint" {
  description = "Confluent Control Center endpoint."
  value       = module.app_services.control_center_endpoint
}

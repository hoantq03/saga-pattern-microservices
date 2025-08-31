# output "kibana_endpoint" {
#   description = "The endpoint for Kibana."
#   value       = kubernetes_service.kibana_svc.status.0.load_balancer.0.ingress.0.hostname
# }

# output "elasticsearch_service_name" {
#   description = "The name of the Elasticsearch service."
#   value       = kubernetes_service.elasticsearch_svc.metadata[0].name
# }

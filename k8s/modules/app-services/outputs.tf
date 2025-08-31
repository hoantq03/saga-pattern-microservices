output "control_center_endpoint" {
  description = "The endpoint for the Confluent Control Center."
  value       = kubernetes_service.control_center_svc.status.0.load_balancer.0.ingress.0.hostname
}

output "kafka_bootstrap_servers" {
  description = "The bootstrap server string for Kafka."
  value       = "${kubernetes_service.broker_svc.metadata[0].name}:9092"
}

output "kafka_exporter_target" {
  description = "The internal DNS name and port for the Kafka Exporter service."
  value = "kafka-exporter-svc.${var.namespace}.svc.cluster.local:9308"
}
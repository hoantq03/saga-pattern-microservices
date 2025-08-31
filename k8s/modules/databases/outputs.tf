output "postgres_services" {
  description = "A map of the created PostgreSQL services."
  value = { for k, v in kubernetes_service.db_svc : k => v.metadata[0].name }
}

output "postgres_exporter_dsn" {
  description = "The Data Source Name (DSN) string for the Postgres Exporter to connect to all databases."
  value = join(",", [
    for k, v in kubernetes_service.db_svc :
    "postgresql://${var.postgres_user}:${var.postgres_password}@${v.metadata[0].name}:${v.spec[0].port[0].port}/${var.postgres_db_name}?sslmode=disable"
  ])
}

output "postgres_exporter_target" {
  description = "The internal DNS name and port for the Postgres Exporter service."
  value = "postgres-exporter-svc.${var.namespace}.svc.cluster.local:9187"
}
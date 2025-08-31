# --- TẠO NAMESPACE VÀ SECRET CHUNG ---

resource "kubernetes_namespace" "app_namespace" {
  metadata {
    name = "saga-app"
  }
}

resource "kubernetes_secret" "postgres_secret" {
  metadata {
    name      = "postgres-secret"
    # Quan trọng: Đảm bảo secret cũng nằm trong namespace saga-app
    namespace = kubernetes_namespace.app_namespace.metadata[0].name
  }
  data = {
    POSTGRES_PASSWORD = var.postgres_password
  }
}

# --- GỌI CÁC MODULE CON ---
# Lưu ý: `namespace` được truyền vào TẤT CẢ các module.

module "databases" {
  source                 = "./modules/databases"
  namespace              = kubernetes_namespace.app_namespace.metadata[0].name
  databases              = var.postgres_databases
  postgres_secret_name   = kubernetes_secret.postgres_secret.metadata[0].name
}

module "messaging" {
  source    = "./modules/messaging"
  namespace = kubernetes_namespace.app_namespace.metadata[0].name
}

module "app_services" {
  source                  = "./modules/app-services"
  namespace               = kubernetes_namespace.app_namespace.metadata[0].name
  kafka_bootstrap_servers = module.messaging.kafka_bootstrap_servers
  schema_registry_url     = "<http://schema-registry-svc.${kubernetes_namespace.app_namespace.metadata[0].name}.svc.cluster.local:8081>"
  depends_on = [
    module.messaging,
    module.databases
  ]
}

# module "logging" {
#   source                = "./modules/logging"
#   namespace             = kubernetes_namespace.app_namespace.metadata[0].name
# }

# module "monitoring" {
#   source                    = "./modules/monitoring"
#   namespace                 = kubernetes_namespace.app_namespace.metadata[0].name
#   postgres_exporter_dsn     = module.databases.postgres_exporter_dsn
#   kafka_server_target       = module.messaging.kafka_bootstrap_servers
#   kafka_exporter_target     = module.messaging.kafka_exporter_target
#   postgres_exporter_target  = module.databases.postgres_exporter_target
#   depends_on = [
#     module.databases,
#     module.messaging
#   ]
# }

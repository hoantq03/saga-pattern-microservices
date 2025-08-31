# k8s/modules/app-services/main.tf

# Đọc manifest vào locals để tái sử dụng
locals {
  app_configmap_manifest    = yamldecode(file("${path.module}/manifests/app-configmap.yaml"))
  customer_deployment_manifest = yamldecode(file("${path.module}/manifests/customer-deployment.yaml"))
  customer_hpa_manifest     = yamldecode(file("${path.module}/manifests/customer-hpa.yaml"))
  customer_service_manifest = yamldecode(file("${path.module}/manifests/customer-service.yaml"))
  gateway_deployment_manifest = yamldecode(file("${path.module}/manifests/gateway-deployment.yaml"))
  gateway_service_manifest  = yamldecode(file("${path.module}/manifests/gateway-service.yaml"))
}

# --- Tài nguyên từ các file manifest YAML ---
resource "kubernetes_manifest" "app_configmap" {
  manifest = merge(local.app_configmap_manifest, {
    metadata = merge(local.app_configmap_manifest.metadata, { # Deep merge
      namespace = var.namespace
    })
  })
}

# customers
resource "kubernetes_manifest" "customer_deployment" {
  manifest = merge(local.customer_deployment_manifest, {
    metadata = merge(local.customer_deployment_manifest.metadata, { # Deep merge
      namespace = var.namespace
    })
  })

  # lifecycle {
  #   ignore_changes = [
  #     # Bảo Terraform phớt lờ mọi thay đổi đối với trường spec.replicas
  #     # do một hệ thống bên ngoài (HPA) thực hiện.
  #     "object.spec.replicas",
  #   ]
  # }

  depends_on = [kubernetes_manifest.app_configmap]
}

resource "kubernetes_manifest" "customer_hpa" {
  manifest = merge(local.customer_hpa_manifest, {
    metadata = merge(local.customer_hpa_manifest.metadata, { # Deep merge
      namespace = var.namespace
    })
  })
  depends_on = [kubernetes_manifest.customer_deployment]
}

resource "kubernetes_manifest" "customer_service" {
  manifest = merge(local.customer_service_manifest, {
    metadata = merge(local.customer_service_manifest.metadata, { # Deep merge
      namespace = var.namespace
    })
  })
}

# gateway
resource "kubernetes_manifest" "gateway_deployment" {
  manifest = merge(local.gateway_deployment_manifest, {
    metadata = merge(local.gateway_deployment_manifest.metadata, { # Deep merge
      namespace = var.namespace
    })
  })
  depends_on = [kubernetes_manifest.app_configmap]
}

resource "kubernetes_manifest" "gateway_service" {
  manifest = merge(local.gateway_service_manifest, {
    metadata = merge(local.gateway_service_manifest.metadata, { # Deep merge
      namespace = var.namespace
    })
  })
}


# --- Consul ---
resource "kubernetes_deployment" "consul" {
  metadata {
    name      = "consul"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "consul" } }
    template {
      metadata { labels = { app = "consul" } }
      spec {
        container {
          name  = "consul"
          image = "hashicorp/consul:latest"
          port { container_port = 8500 }
        }
      }
    }
  }
}
resource "kubernetes_service" "consul_svc" {
  metadata {
    name      = "consul-svc"
    namespace = var.namespace
  }
  spec {
    selector = { app = "consul" }
    port {
      port = 8500
      target_port = 8500
    }
    type     = "LoadBalancer"
  }
}

# --- Kafka Connect ---
resource "kubernetes_deployment" "connect" {
  metadata {
    name      = "connect"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "connect" } }
    template {
      metadata { labels = { app = "connect" } }
      spec {
        container {
          name  = "connect"
          image = "confluentinc/cp-kafka-connect:7.5.0"
          port { 
            container_port = 8083 
          }
          env {
            name = "CONNECT_BOOTSTRAP_SERVERS"
            value = var.kafka_bootstrap_servers
          }
          env {
            name = "CONNECT_REST_ADVERTISED_HOST_NAME"
            value = "connect-svc"
          }
          env {
            name = "CONNECT_GROUP_ID"
            value = "compose-connect-group"
          }
          env {
            name = "CONNECT_CONFIG_STORAGE_TOPIC"
            value = "docker-connect-configs"
          }
          env {
            name = "CONNECT_CONFIG_STORAGE_REPLICATION_FACTOR"
            value = "1"
          }
          env {
            name = "CONNECT_OFFSET_FLUSH_INTERVAL_MS"
            value = "10000"
          }
          env {
            name = "CONNECT_OFFSET_STORAGE_TOPIC"
            value = "docker-connect-offsets"
          }
          env {
            name = "CONNECT_OFFSET_STORAGE_REPLICATION_FACTOR"
            value = "1"
          }
          env {
            name = "CONNECT_STATUS_STORAGE_TOPIC"
            value = "docker-connect-status"
          }
          env {
            name = "CONNECT_STATUS_STORAGE_REPLICATION_FACTOR"
            value = "1"
          }
          env {
            name = "CONNECT_KEY_CONVERTER"
            value = "org.apache.kafka.connect.storage.StringConverter"
          }
          env {
            name = "CONNECT_VALUE_CONVERTER"
            value = "io.confluent.connect.avro.AvroConverter"
          }
          env {
            name = "CONNECT_VALUE_CONVERTER_SCHEMA_REGISTRY_URL"
            value = var.schema_registry_url
          }
          env {
            name = "CONNECT_PLUGIN_PATH"
            value = "/usr/share/java,/usr/share/confluent-hub-components"
          }
          args = [
            "bash", "-c",
            "confluent-hub install --no-prompt debezium/debezium-connector-postgresql:latest && /etc/confluent/docker/run"
          ]
        }
      }
    }
  }
}

resource "kubernetes_service" "connect_svc" {
  metadata {
    name      = "connect-svc"
    namespace = var.namespace
  }
  spec {
    selector = { app = "connect" }
    port {
      port = 8083
      target_port = 8083
    }
    type     = "LoadBalancer"
  }
}

# --- Control Center ---
resource "kubernetes_deployment" "control_center" {
  metadata {
    name      = "control-center"
    namespace = var.namespace
  }
  spec {
    replicas = 1
    selector { match_labels = { app = "control-center" } }
    template {
      metadata { labels = { app = "control-center" } }
      spec {
        container {
          name  = "control-center"
          image = "confluentinc/cp-enterprise-control-center:7.5.0"
          port { container_port = 9021 }
          env {
            name = "CONTROL_CENTER_BOOTSTRAP_SERVERS"
            value = var.kafka_bootstrap_servers
          }
          env {
            name = "CONTROL_CENTER_CONNECT_CONNECT-DEFAULT_CLUSTER"
            value = "connect-svc:8083"
          }
          env {
            name = "CONTROL_CENTER_REPLICATION_FACTOR"
            value = "1"
          }
          env {
            name = "PORT"
            value = "9021"
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "control_center_svc" {
  metadata {
    name      = "control-center-svc"
    namespace = var.namespace
  }
  spec {
    selector = { app = "control-center" }
    port {
      port = 9021
      target_port = 9021
    }
    type     = "LoadBalancer"
  }
}

resource "kubernetes_stateful_set" "broker" {
  metadata {
    name      = "broker"
    namespace = var.namespace
  }
  spec {
    service_name = "broker-svc"
    replicas     = 1
    selector { match_labels = { app = "broker" } }
    template {
      metadata { labels = { app = "broker" } }
      spec {
        termination_grace_period_seconds = 30
        container {
          name  = "broker"
          image = "confluentinc/cp-server:7.5.0"
          port { container_port = 9092 }
          port { container_port = 29093 }
          env { 
            name = "KAFKA_HEAP_OPTS"
            value = "-Xms512m -Xmx512m"
          }
          env {
            name = "KAFKA_NODE_ID"
            value = "1"
          }
          env {
            name = "KAFKA_PROCESS_ROLES"
            value = "broker,controller"
          }
          env {
            name = "KAFKA_LISTENER_SECURITY_PROTOCOL_MAP"
            value = "CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT"
          }
          env {
            name = "KAFKA_ADVERTISED_LISTENERS"
            value = "PLAINTEXT://broker-svc:9092"
          }
          env {
            name = "KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR"
            value = "1"
          }
          env {
            name = "KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS"
            value = "0"
          }
          env {
            name = "KAFKA_TRANSACTION_STATE_LOG_MIN_ISR"
            value = "1"
          }
          env {
            name = "KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR"
            value = "1"
          }
          env {
            name = "KAFKA_CONTROLLER_QUORUM_VOTERS"
            value = "1@broker-0.broker-svc:29093"
          }
          env {
            name = "KAFKA_LISTENERS"
            value = "PLAINTEXT://0.0.0.0:9092,CONTROLLER://0.0.0.0:29093"
          }
          env {
            name = "KAFKA_INTER_BROKER_LISTENER_NAME"
            value = "PLAINTEXT"
          }
          env {
            name = "KAFKA_CONTROLLER_LISTENER_NAMES"
            value = "CONTROLLER"
          }
          env {
            name = "KAFKA_LOG_DIRS"
            value = "/var/lib/kafka/data"
          }
          env {
            name = "CLUSTER_ID"
            value = "MkU3OEVBNTcwNTJENDM2Qk"
          }
          volume_mount {
            name       = "kafka-data"
            mount_path = "/var/lib/kafka/data"
          }
        }
      }
    }
    volume_claim_template {
      metadata { name = "kafka-data" }
      spec {
        access_modes = ["ReadWriteOnce"]
        resources { requests = { storage = "5Gi" } }
      }
    }
  }
}

resource "kubernetes_service" "broker_svc" {
  metadata {
    name      = "broker-svc"
    namespace = var.namespace
  }
  spec {
    selector   = { app = "broker" }
    port {
      port = 9092
      target_port = 9092
    }
    cluster_ip = "None"
  }
}

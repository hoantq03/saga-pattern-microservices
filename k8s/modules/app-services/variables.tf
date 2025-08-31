variable "kafka_bootstrap_servers" {
  description = "The connection string for the Kafka brokers."
  type        = string
}

variable "schema_registry_url" {
  description = "The URL for the Schema Registry."
  type        = string
}

variable "namespace" { 
  description = "The Kubernetes namespace to deploy the application services into."
  type        = string
}

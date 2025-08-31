variable "kube_config_path" {
  description = "Path to the Kubernetes config file."
  type        = string
  default     = "~/.kube/config"
}

variable "kube_config_context" {
  description = "The context to use from the Kubernetes config file."
  type        = string
  default     = "docker-desktop"
}

variable "postgres_password" {
  description = "Password for the PostgreSQL databases."
  type        = string
  default     = "postgres"
  sensitive   = true
}

variable "postgres_databases" {
  description = "A map of PostgreSQL databases to create."
  type = map(object({
    storage = string
  }))
  default = {
    orderdb     = { storage = "1Gi" }
    customerdb  = { storage = "1Gi" }
    inventorydb = { storage = "1Gi" }
  }
}

variable "databases" {
  description = "A map of databases to create."
  type        = map(object({ storage = string }))
}

variable "postgres_secret_name" {
  description = "The name of the Kubernetes secret for the PostgreSQL password."
  type        = string
}

variable "postgres_image" {
  description = "The Docker image for PostgreSQL."
  type        = string
  default     = "debezium/postgres:11"
}

variable "postgres_user" {
  description = "Username for PostgreSQL."
  type        = string
  default     = "postgres"
}

variable "postgres_db_name" {
  description = "Database name for PostgreSQL."
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "The password for the PostgreSQL user. It's used here to construct the DSN."
  type        = string
  sensitive   = true
  default     = "postgres"
}

variable "namespace" { 
  description = "The Kubernetes namespace to deploy the database services into."
  type        = string
}

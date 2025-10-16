variable "hostname" {
  description = "Server hostname"
  type        = string
  default     = "my-server"
}

variable "zone" {
  description = "UpCloud zone"
  type        = string
  default     = "us-nyc1"
}

variable "vm_type" {
  description = "VM plan/size"
  type        = string
  default     = "2xCPU-4GB"
}

variable "storage_size" {
  description = "Storage size in GB"
  type        = number
  default     = 50
}

# Required by your Rego policies
variable "labels" {
  description = "Key/value labels applied to the server"
  type        = map(string)
  default = {
    environment = "dev"
    managed_by  = "opentofu"
  }
  validation {
    condition     = contains(keys(var.labels), "environment") && contains(keys(var.labels), "managed_by")
    error_message = "labels must include keys 'environment' and 'managed_by'."
  }
}

#Encryption
variable "encryption_passphrase" {
  description = "Passphrase for state encryption"
  type        = string
  sensitive   = true
}

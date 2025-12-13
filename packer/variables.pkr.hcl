variable "build_name" {
  type = string
  description = "Name of Image to be Built"
}

variable "build_version" {
  type = string
  description = "String for Versioning Built Image"
}

variable "build_cpus" {
  type = number
  description = "Number of CPUs to use during build"

  validation {
    condition     = var.build_cpus >= 1
    error_message = "At least 1 CPU must be used during build."
  }
}

variable "build_memory" {
  type = number
  description = "Amount of Memory in MB to use during build"

  validation {
    condition     = var.build_memory >= 512
    error_message = "At least 512 MB must be used during build."
  }
}

variable "boot_wait_time" {
  type = number
  description = "Number of Seconds to wait until typing boot command"

  validation {
    condition     = var.boot_wait_time >= 30
    error_message = "At least 30 seconds wait time is required."
  }
}

variable "image_cpus" {
  type = number
  description = "Number of CPUs to use in Exported Image"

  validation {
    condition     = var.image_cpus >= 1
    error_message = "At least 1 CPU must be used in Exported Image."
  }
}

variable "image_memory" {
  type = number
  description = "Amount of Memory in MB to use in Exported Image"

  validation {
    condition     = var.image_memory >= 512
    error_message = "At least 512 MB must be used in Exported Image."
  }
}

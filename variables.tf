variable "basename" {
  type        = string
  default     = "dev"
  description = "Prefix for all resource names"
}

variable "subnets" {
  type = map(any)
  default = {
    sub-1 = {
      az       = "us-east-1a"
      cidr_prv = "10.0.1.0/24"
      cidr_pub = "10.0.101.0/24"
    }
    sub-2 = {
      az       = "us-east-1b"
      cidr_prv = "10.0.2.0/24"
      cidr_pub = "10.0.102.0/24"
    }

  }
  description = "Defines subnets and availibility zones"
}

variable "cidr_vpc" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Vpc cidr"
}

variable "azs" {
  type        = list(string)
  default     = []
  description = "description"
}

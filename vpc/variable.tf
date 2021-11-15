variable "tag_name" {
  default = {
    Name    = "Test"
    Env     = "Dev"
    Created = "Terraform"
  }
  description = "Sets tags for the resource"
}

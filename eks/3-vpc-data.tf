data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "terraform-state-vrahul-mumbai"
    key    = "vpc/dev/terraform.tfstate"
    region = local.region
  }
}
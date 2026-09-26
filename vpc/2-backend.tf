terraform {
  backend "s3" {
    bucket       = "terraform-state-vrahul-mumbai"
    key          = "vpc/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
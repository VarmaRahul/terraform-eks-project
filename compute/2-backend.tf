terraform {
  backend "s3" {
    bucket       = "terraform-state-vrahul-mumbai"
    key          = "compute/dev/terraform.tfstate"
    region       = "ap-south-1"
    encrypt      = true
    use_lockfile = true
  }
}
provider "scaleway" {
  region  = "${var.region}"
  organization = "${var.scaleway_organization}"
  token = "${var.scaleway_token}"
  version = "1.8.0"
}

provider "external" {
  version = "1.0.0"
}

// mother fuckers https://api-marketplace.scaleway.com/images
data "scaleway_image" "nodes_os_image" {
  architecture = "${var.arch}"
  name         = "Ubuntu Xenial"
}

data "scaleway_image" "masters_os_image" {
  architecture = "${var.arch}"
  name         = "Ubuntu Xenial"
}

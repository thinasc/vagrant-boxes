packer {
  required_plugins {
    ansible = {
      source  = "github.com/hashicorp/ansible"
      version = "~> 1"
    }

    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> v1.1.1"
    }

    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1.0.5"
    }
  }
}

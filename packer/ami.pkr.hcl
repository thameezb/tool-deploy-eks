packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.1"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

source "amazon-ebs" "ag-ret-eks" {
  ami_description = "An AMI that has required eks components"
  ami_name      = "ag-ret-eks-{{timestamp}}"
  instance_type = "t3.micro"
  region         = var.region

  ssh_username   = "ubuntu"

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    encrypted             = true
    delete_on_termination = true
    volume_size           = 100
    volume_type           = "gp2"
  }
  
  subnet_filter {
    filters = {
      "tag:tier" = "compute"
    }
    most_free = true
    random    = true
  }
  
  vpc_filter {
    filters = {
      "tag:Name": "ag-ret-${var.environment}-${var.region}",
    }
  }

  source_ami_filter {
    filters = {
      name                = "ubuntu-eks/k8s_1.20/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-2022*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] # canonical
    most_recent = true
  }
  
  tags = local.tags
  run_tags = local.tags
  run_volume_tags = local.tags
}

build {
  sources = ["source.amazon-ebs.ag-ret-eks"]

  provisioner "file" {
    source      = "sources.list"
    destination = "/tmp/sources.list"
  }
  provisioner "shell" {
    script          = "provision.sh"
    execute_command = "{{.Vars}} bash '{{.Path}}'"
  }
  post-processor "manifest" {
    output     = "manifest.json"
    strip_path = true
  }
}

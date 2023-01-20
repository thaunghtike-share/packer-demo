data "amazon-ami" "ubuntu_arm" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/*ubuntu-jammy-22.04-arm64-server-*"
    root-device-type    = "ebs"
    architecture        = "arm64"
  }
  owners      = ["099720109477"]
  most_recent = true
}

source "amazon-ebs" "ubuntu_arm" {
  ami_name      = "flowtune-ubuntu-${var.ubuntu_version}-arm64"
  instance_type = "c6g.medium"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.ubuntu_arm.id
  ssh_username  = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu_arm"
  ]

  provisioner "shell" {
    inline = [
      "mkdir actions-runner && cd actions-runner",
      "curl -o actions-runner-osx-arm64-2.300.2.tar.gz -L https://github.com/actions/runner/releases/download/v2.300.2/actions-runner-osx-arm64-2.300.2.tar.gz",
      "echo 'c52f30610674acd0ea7c2d05e65c04c1dedf1606c2f00ce347640a001bafc568  actions-runner-osx-arm64-2.300.2.tar.gz' | shasum -a 256 -c",
      "tar xzf ./actions-runner-osx-arm64-2.300.2.tar.gz"
    ]
  }

  post-processor "manifest" {
    output     = "ubuntu_arm64.json"
    strip_path = true
  }
}
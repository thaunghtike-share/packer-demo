data "amazon-ami" "ubuntu_x86" {
  filters = {
    virtualization-type = "hvm"
    name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
    root-device-type    = "ebs"
    architecture        = "x86_64"
  }
  owners      = ["099720109477"]
  most_recent = true
}

source "amazon-ebs" "ubuntu_x86" {
  ami_name      = "flowtune-ubuntu-${var.ubuntu_version}-x86"
  instance_type = "t2.micro"
  region        = "us-east-1"
  source_ami    = data.amazon-ami.ubuntu_x86.id
  ssh_username  = "ubuntu"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu_x86"
  ]

  provisioner "shell" {
    inline = [
      "mkdir actions-runner && cd actions-runner",
      "curl -o actions-runner-linux-x64-2.300.2.tar.gz -L https://github.com/actions/runner/releases/download/v2.300.2/actions-runner-linux-x64-2.300.2.tar.gz",
      "echo 'ed5bf2799c1ef7b2dd607df66e6b676dff8c44fb359c6fedc9ebf7db53339f0c  actions-runner-linux-x64-2.300.2.tar.gz' | shasum -a 256 -c",
      "tar xzvf ./actions-runner-linux-x64-2.300.2.tar.gz"
    ]
  }

  post-processor "manifest" {
    output     = "ubuntu_x64.json"
    strip_path = true
  }
}
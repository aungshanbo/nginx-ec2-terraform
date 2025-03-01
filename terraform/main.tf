
resource "aws_key_pair" "nginx_server_ssh_key" {
  key_name   = var.ssh_key_name
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_security_group" "nginx_sg" {
  name        = var.security_groups
  description = "Allow SSH, HTTP, and HTTPS access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx_server" {
  ami             = var.ami
  instance_type   = var.instance_type
  key_name        = var.ssh_key_name
  security_groups = [aws_security_group.nginx_sg.name]


  provisioner "file" {
    source      = "./nginx-ec2-terraform/nginx/nginx.conf"
    destination = "/tmp/"
    connection {
      type = "ssh"
      host = self.private_ip
      user        = "ubuntu"
      private_key = file("/home/kenji/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "./nginx-ec2-terraform/nginx/site-available"
    destination = "/tmp/"
    connection {
      type = "ssh"
      host = self.private_ip
      user        = "ubuntu"
      private_key = file("/home/kenji/.ssh/id_rsa")
    }
  }
  provisioner "file" {
    source      = "./nginx-ec2-terraform/project_folder"
    destination = "/tmp/project_folder"
    connection {
      type = "ssh"
      host = self.private_ip
      user        = "ubuntu"
      private_key = file("/home/kenji/.ssh/id_rsa")
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo cp /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo cp /tmp/sites-available/python-service /etc/nginx/sites-available/python-service",
      "sudo cp /tmp/sites-available/node-service /etc/nginx/sites-available/node-service",
      "sudo ln -s /etc/nginx/sites-available/python-service /etc/nginx/sites-enabled/",
      "sudo ln -s /etc/nginx/sites-available/node-service /etc/nginx/sites-enabled/",
      "sudo systemctl restart nginx"
    ]
    connection {
      type        = "ssh"
      host        = self.private_ip
      user        = "ubuntu"
      private_key = file("/home/kenji/.ssh/id_rsa")
    }
  }
  tags = {
    Name = "nginx_server_ec2"
  }
}


resource "aws_route53_zone" "nginx_zone" {
  name = var.domain
}

resource "aws_route53_record" "nginx_dns" {
  zone_id = aws_route53_zone.nginx_zone.zone_id
  name    = var.nginx_server_url
  type    = "A"
  ttl     = 300
  records = [aws_eip.nginx_eip.public_ip]
}

resource "aws_eip" "nginx_eip" {
    instance = aws_instance.nginx_server.id
}

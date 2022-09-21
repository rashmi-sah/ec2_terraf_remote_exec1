#### This file creates aws ec2 server and stores ec2 public IP in output variable
resource "aws_instance" "aws_ec_instance" {
  ami = "ami-052efd3df9dad4825"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.publicsubnets.id
  associate_public_ip_address = true
  key_name = "AWS_EC2_key"

  connection {
    type="ssh"
    user = "ubuntu"
    host=self.public_ip
    private_key=file("/home/runner/work/ec2_terraf_remote_exec1/ec2_terraf_remote_exec1/prv_key.ppk")
    #agent = true
    timeout = "4m"
  }

  provisioner "file" {
    source      = "/home/runner/work/ec2_terraf_remote_exec1/ec2_terraf_remote_exec1/install_python.sh"
    destination = "/tmp/install_python.sh"
  }
  
  provisioner "remote-exec" {
    inline = [
      "touch hello.txt",
      "echo helloworld remote provisioner > hello.txt",
      "echo hello Rashmi >> hello.txt",
      "sh /tmp/install_python.sh >> /tmp/output_install_python.txt"
    ]
  }

  vpc_security_group_ids = [
    aws_security_group.aws_ec_sg.id
  ]
  root_block_device {
    delete_on_termination = true
    volume_size = 8
    volume_type = "gp2"
  }
  tags = {
    Name ="Ubuntu_Terraform"
    Environment = "DEV"
    OS = "UBUNTU"
    Managed = "IAC"
  }

  depends_on = [ aws_security_group.aws_ec_sg ]
}



resource "aws_security_group" "aws_ec_sg" {
  name = "terraform-Sec-Group"
  description = "terraform-Sec-Group"
  vpc_id = aws_vpc.Main.id
  tags = {
    Name ="Git_sg"
  }
}

resource "aws_security_group_rule" "ingress_rule1" {
      type              = "ingress"
      from_port         = 22
      to_port           = 22
      protocol          = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      security_group_id = "${aws_security_group.aws_ec_sg.id}"
    }

resource "aws_security_group_rule" "ingress_rule2" {
      type              = "ingress"
      from_port         = 0
      to_port           = 0
      protocol          = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      security_group_id = "${aws_security_group.aws_ec_sg.id}"
    }

 resource "aws_security_group_rule" "egress_all1" {
      type              = "egress"
      from_port         = 0
      to_port           = 0
      protocol          = "-1"
      cidr_blocks       = ["0.0.0.0/0"]
      security_group_id = "${aws_security_group.aws_ec_sg.id}"
    }



output "ec2instance" {
  value = aws_instance.aws_ec_instance.public_ip
}

output "ec2dns" {
  value = aws_instance.aws_ec_instance.public_dns
}

resource "local_file" "ip" {
   content  = aws_instance.aws_ec_instance.public_ip
    filename = "ip.txt"
}

#resource "null_resource" "nullremote1" {
#depends_on = [aws_instance.aws_ec_instance] 
#connection {
 #type     = "ssh"
 #user     = "ubuntu"
 #port        = 22
 #host= aws_instance.aws_ec_instance.public_ip
#}
  
#provisioner "file" {
 #   source      = "ip.txt"
  #  destination = "ip.txt"
   #    }
#}

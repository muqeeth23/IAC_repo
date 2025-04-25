resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc-main"
  }
}

resource "aws_subnet" "pvtsn1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "mysubnet-pvt"
  }
}
resource "aws_subnet" "pubsn1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "mysubnet-pub"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id      = "local"
  }

  tags = {
    Name = "my-pub-rt"
  }
}


resource "aws_route_table" "pvt-rt" {
  vpc_id = aws_vpc.main.id


  route {
    cidr_block = "10.0.0.0/16"
    gateway_id      = "local"
  }

  tags = {
    Name = "my-pvt-rt"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.pvtsn1.id
  route_table_id = aws_route_table.pvt-rt.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.pubsn1.id
  route_table_id = aws_route_table.pub-rt.id
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDcuRdc9OZdU2VhM5c2a9Ir71CjVRZ6uNZiUlA0v6/K/SU7UjFmxPB2Dlt80pc3G9coPJGL0mJyWKK25iuL8X/s1kweixoojG5Pa5iOc7Fy58HspRoMlnQmaW3GQ4w1c/aa88hxDNjobfKEMnRf1SUEbgMPCUniuTy4RbR8IARM90/19EzG4h++euDiK950/fKFhCDJ+oTlcH16WU6myotTnZZ52NNmY0IWGMcRpBk7PdK+eo3+77bvh7c+RYYfL9KLEP6MNcejZzKaVAN+DwNjvetCYLSoDhON7BJVDGE6fH2Gl0tkn9luXZsGl0JCshPoy+eaLTB+aPgSXUi39vS72mkjuAK4Tt6IYj5k1qwjDoCS8qXYAAPQdUZOUexJuX4aimouENaMdKh7MrKN4Ic6iiHfhErYuwgly4SB5Ux8Yr5dgve81Rt5P2mPcbvcjEp33uRCKyZ3L38qN1e+loAHZriwqOy7ItNYT0TnomkhBnfY14W4VzDjz9YFI7FCTYM= mohammad muqeeth@LAPTOP-6P2JK7PM"
}

resource "aws_instance" "app-server" {
  ami           = "ami-0f1dcc636b69a6438"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.pubsn1.id
  key_name      = aws_key_pair.deployer.id
  vpc_security_group_ids = [aws_security_group.appserversg.id]


  tags = {
    Name = "appserver"
  }
}


resource "aws_security_group" "appserversg" {
  name   = "app-server-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
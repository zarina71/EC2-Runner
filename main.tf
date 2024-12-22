resource "aws_iam_role" "runnerrole" {
  name               = "EC2RunnerRole" 
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "admin_access" {
  role       = aws_iam_role.runnerrole.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_instance_profile" "runnerinstance-profile" {
  name = "Github-runner-profile"
  role = aws_iam_role.runnerrole.name
}

resource "aws_security_group" "runner-sg" {
  description = "Allowing Sonarqube, SSH Access"

  ingress {
    description      = "Allow SSH from specific IP range"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    # Allow SSH access only from EC2 Instance Connect
    cidr_blocks      = ["3.8.37.24/29"]  
    ipv6_cidr_blocks = []
    self             = false
    prefix_list_ids  = []
    security_groups  = []
  }

  ingress {
    description      = "Allow SonarQube from anywhere"
    from_port        = 9000
    to_port          = 9000
    protocol         = "tcp"
    # Open SonarQube to the internet
    cidr_blocks      = ["0.0.0.0/0"]  
    ipv6_cidr_blocks = ["::/0"]
    self             = false
    prefix_list_ids  = []
    security_groups  = []
  }

  ingress {
    description      = "Allow access to application from anywhere"
    from_port        = 3000
    to_port          = 3000
    protocol         = "tcp"
    # Open SonarQube to the internet
    cidr_blocks      = ["0.0.0.0/0"]  
    ipv6_cidr_blocks = ["::/0"]
    self             = false
    prefix_list_ids  = []
    security_groups  = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "runner-sg"
  }
}


resource "aws_instance" "runner-ec2" {
  ami                    = data.aws_ami.ami.image_id
  instance_type          = "t2.large"
  # Replace below with your keypair name
  key_name               = "DemoKeyPair2"
  vpc_security_group_ids = [aws_security_group.runner-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.runnerinstance-profile.name
  root_block_device {
    volume_size = 30
  }
  user_data = file("./InstallTools.sh")
  tags = {
    Name = "GITHUBRUNNER"
  }
}

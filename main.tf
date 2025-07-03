provider "aws"{
    region = var.aws_region
}

resource "aws_s3_bucket" "backup_bucket"{
    bucket = var.bucket_name
}

resource "aws_iam_role"  "ec2_role"{
    name = "s3-read-role"
    assume_role_policy = jsonencode ({
        Version = "2012-10-17",
        Statement = [{
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
            Service = "ec2.amazonaws.com"
      }
    }]
    })
}

resource "aws_iam_role_policy" "s3_read_policy" {
  name = "s3-read-policy"
  role = aws_iam_role.ec2_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ],
        Resource = [
          aws_s3_bucket.backup_bucket.arn,
          "${aws_s3_bucket.backup_bucket.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "s3-read-profile"
  role = aws_iam_role.ec2_role.name

  depends_on = [aws_iam_role.ec2_role]
}


data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"] # Amazon official AMIs

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_security_group" "ec2_sg" {
  name        = "ec2-s3-access"
  description = "Allow SSH"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "notifier_instance" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  security_groups             = [aws_security_group.ec2_sg.name]
  associate_public_ip_address = true
  user_data                   = file("user_data.sh")

  tags = {
    Name = "S3Notifier"
  }
}
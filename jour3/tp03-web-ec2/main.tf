
# -----------------------------------------------------------------------------
# Data source : AMI Amazon Linux 2023
# -----------------------------------------------------------------------------
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------------------------------------------------------
# Key pair : cle SSH publique de noura
# -----------------------------------------------------------------------------
resource "aws_key_pair" "formation" {
  key_name   = "etudiant07-noura-tp03-key"
  public_key = file("~/.ssh/id_rsa.pub")

  tags = {
    Owner = "etudiant07"
  }
}

# -----------------------------------------------------------------------------
# Security Group : instances web
# -----------------------------------------------------------------------------
resource "aws_security_group" "web" {
  name        = "${local.name_prefix}-web-sg"
  description = "Allow SSH/HTTP from bastion SG only"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name  = "${local.name_prefix}-web-sg"
    Owner = "etudiant07"
  }
}

resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id            = aws_security_group.web.id
  description                  = "SSH depuis le bastion"
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion.id

  tags = { Owner = "etudiant07" }
}

resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id            = aws_security_group.web.id
  description                  = "HTTP depuis le bastion"
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.bastion.id

  tags = { Owner = "etudiant07" }
}

resource "aws_vpc_security_group_egress_rule" "web_all" {
  security_group_id = aws_security_group.web.id
  description       = "Egress all (dnf/nginx updates)"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"

  tags = { Owner = "etudiant07" }
}

# -----------------------------------------------------------------------------
# EC2 bastion (subnet public AZ-a)
# -----------------------------------------------------------------------------
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public[var.azs[0]].id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.formation.key_name

  tags = {
    Name  = "${local.name_prefix}-noura-bastion"
    Role  = "bastion"
    Owner = "etudiant07"
  }
}

# -----------------------------------------------------------------------------
# EIP bastion
# -----------------------------------------------------------------------------
resource "aws_eip" "bastion" {
  instance = aws_instance.bastion.id
  domain   = "vpc"

  tags = {
    Name  = "${local.name_prefix}-noura-bastion-eip"
    Owner = "etudiant07"
  }

  depends_on = [aws_internet_gateway.main]
}

# -----------------------------------------------------------------------------
# EC2 web (1 par AZ via for_each)
# -----------------------------------------------------------------------------
resource "aws_instance" "web" {
  for_each = local.web_subnets

  ami                    = data.aws_ami.al2023.id
  instance_type          = var.instance_type
  subnet_id              = each.value
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = aws_key_pair.formation.key_name

  user_data = templatefile("${path.module}/templates/nginx.sh.tftpl", {
    az = each.key
  })

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name  = "${local.name_prefix}-noura-web-${each.key}"
    Role  = "web"
    AZ    = each.key
    Owner = "etudiant07"
  }
}
   
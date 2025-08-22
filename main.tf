/*
Création infrastructure OMEGA as code
avec Terraform
*/
#Configuration provider AWS
provider "aws" {
  region     = var.region_aws
  #access_key = var.access_key_aws
  #secret_key = var.secret_key_aws
}

#Creation VPC prd
resource "aws_vpc" "vpc_prd" {
  cidr_block = var.vpc_prd_cidr
  # We want DNS hostnames enabled for this VPC
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_prd_name}"
  }
}

//Creation intenet gateway et l attacher au VPC

resource "aws_internet_gateway" "prd_igw" {
  //Attacher VPC a igw
  vpc_id = aws_vpc.vpc_prd.id
  //tags
  tags = {
    Name = "${var.gateway_name}"
  }
}

//Creation de groupe subnet publique basé sur la variable subnet_count.public

resource "aws_subnet" "omega_prd_public_subnet" {
  count             = var.subnet_count.public
  vpc_id            = aws_vpc.vpc_prd.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.group_public_subnets_name}${count.index}"
  }

}

//Creation de groupe subnet privee basé sur la variable subnet_count.public

resource "aws_subnet" "omega_prd_private_subnet" {
  count             = var.subnet_count.private
  vpc_id            = aws_vpc.vpc_prd.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.group_private_subnets_name}${count.index}"
  }

}

//Creation route table public

resource "aws_route_table" "omega_prd_public_rt" {
  vpc_id = aws_vpc.vpc_prd.id
  route {
    cidr_block = var.rt_omega_backend
    gateway_id = aws_internet_gateway.prd_igw.id
  }
}

//Associer route table > subnet publique

resource "aws_route_table_association" "public" {
  count          = var.subnet_count.public
  route_table_id = aws_route_table.omega_prd_public_rt.id
  subnet_id      = aws_subnet.omega_prd_public_subnet[count.index].id
}

//Creation route table prive

resource "aws_route_table" "omega_prd_private_rt" {
  vpc_id = aws_vpc.vpc_prd.id
}

//Associer route table > subnet prive

resource "aws_route_table_association" "private" {
  count          = var.subnet_count.private
  route_table_id = aws_route_table.omega_prd_private_rt.id
  subnet_id      = aws_subnet.omega_prd_private_subnet[count.index].id
}

//Creation groupe securite EC2 backend

resource "aws_security_group" "omega_prd_backend_sg" {
  name        = "omega_prd_backend_sg"
  description = "Groupe securite omega"
  vpc_id      = aws_vpc.vpc_prd.id
/*
  ingress {
    description = "Allow all traffic through HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks_http
  }
  ingress {
    description = "For Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks_http
  }

  ingress {
    description = "For prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks_http
  }
  ingress {
    description = "For pushgateway"
    from_port   = 9091
    to_port     = 9091
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks_http
  }


  ingress {
    description = "For Node-exporter"
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks_http
  }
  ingress {
    description = "For Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks_http
  }
  ingress {
    description = "for tomcat"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks_http
  }

*/

  ingress {
sg-danie
    description = "danie"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.acc_machines["danielle-tatouopa"]]

    description = "ange-danielle"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.acc_machines["ange-danielle"]]
  }
 ingress {
    description = "ahcene"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =[var.acc_machines["ahcene"]]

  }
  
 ingress {
    description = "BVS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.acc_machines["bvs"]]
   }

  ingress {
    description = "Allow All trafic from prd_frontend"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.flow_opening["omega_prd_frontend"]]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   =  0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Omega Security Group"
  }

}
//Creation groupe securite EC2 frontend

resource "aws_security_group" "omega_prd_frontend_sg" {
  name        = var.sg_omega_name_frontend
  description = "Groupe securite omega frontend"
  vpc_id      = aws_vpc.vpc_prd.id

/*

  ingress {
    description = "Allow all traffic through HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks_http
  }

  ingress {
    description = "For Tomacat"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks_http
  }

  ingress {
    description = "Allow SSH from my computer"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks_ssh
  }

ingress {
    description = "For Grafana"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks_http
  }

  ingress {
    description = "for prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks_http
  }
  ingress {
    description = "For pushgateway"
    from_port   = 9091
    to_port     = 9091
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks_http
  }

*/

  ingress {

    description = "danie"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.acc_machines["danielle-tatouopa"]]

    description = "ange-danielle"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.acc_machines["ange-danielle"]]
  }
ingress {
    description = "ahcene"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.acc_machines["ahcene"]]
  }
  
ingress {
    description = "BVS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.acc_machines["bvs"]]


  }

    ingress {
    description = "Allow All trafic from prd_backend"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.flow_opening["omega_prd_backend"]]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_omega_name_frontend
  }
}


//Creation groupe securite RDS

resource "aws_security_group" "omega_prd_db_sg" {
  name        = "omega_prd_db_sg"
  description = "Groupe securite omega db"
  vpc_id      = aws_vpc.vpc_prd.id

  ingress {
    description     = "Allow postgresdatabase traffic from only the web sg"
    from_port       = var.settings.database.port
    to_port         = var.settings.database.port
    protocol        = "tcp"
    security_groups = [aws_security_group.omega_prd_backend_sg.id]
  }
  tags = {
    Name = "${var.sg_omega_db_name}"
  }
}

//Création groupe subnet RDS "omega_db_subnet_group"

resource "aws_db_subnet_group" "omega_prd_db_subnet_group" {
  //name ="${var.omega_db_subnet_gr_name}"
  description = "Groupe securité subnet"
  subnet_ids  = [for subnet in aws_subnet.omega_prd_private_subnet : subnet.id]
  tags = {
    Name = "${var.omega_db_subnet_gr_name}"
  }
}

//Création base RDS "omega_database"
/*
resource "aws_db_instance" "omega_database" {
  identifier             = "rds-postgres"
  allocated_storage      = var.settings.database.allocated_storage
  engine                 = var.settings.database.engine
  engine_version         = var.settings.database.engine_version
  instance_class         = var.settings.database.instance_class
  db_name                = var.settings.database.db_name
  username               = var.settings.database.db_username
  password               = var.settings.database.db_password
  db_subnet_group_name   = aws_db_subnet_group.omega_db_subnet_group.id
  vpc_security_group_ids = [aws_security_group.omega_db_sg.id]
  skip_final_snapshot    = var.settings.database.skip_final_snapshot
  tags = {
    Name = "${var.settings.database.db_name}"
  }
}
*/
//Création key_pair backend

resource "tls_private_key" "omega_prd_backend_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "omega_prd_backend_key_pair" {
  key_name   = "omega_prd_backend_key"
  public_key = tls_private_key.omega_prd_backend_key.public_key_openssh
  provisioner "local-exec" {
    command = "echo '${tls_private_key.omega_prd_backend_key.private_key_pem}' > ~/keyAws/omega_prd_back.pem"
  }
}
//Création key_pair frontend

resource "tls_private_key" "omega_prd_frontend_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "omega_prd_frontend_key_pair" {
  key_name   = "omega_prd_frontend_key"
  public_key = tls_private_key.omega_prd_frontend_key.public_key_openssh
  provisioner "local-exec" {
    command = "echo '${tls_private_key.omega_prd_frontend_key.private_key_pem}' > ~/keyAws/omega_prd_front.pem"
  }
}

//Création instace EC2 omega_backend

resource "aws_instance" "omega_prd_backend" {
  ami                    = "ami-07e67bd6b5d9fd892"
  count                  = var.settings.omega_prd_backend.count
  instance_type          = var.settings.omega_prd_backend.instance_type
  key_name               = aws_key_pair.omega_prd_backend_key_pair.key_name
  subnet_id              = aws_subnet.omega_prd_public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.omega_prd_backend_sg.id]
  tags = {
    Name = "prd_omega_backend"
  }
}

//Reserver IP fixe backend

resource "aws_eip" "omega_prd_eip" {
  count    = var.settings.omega_prd_backend.count
  instance = aws_instance.omega_prd_backend[count.index].id
  vpc      = true
  tags = {
    Name = "${var.eip_name}${count.index}"
  }
}

//Reserver IP fixe frontend

resource "aws_eip" "omega_prd_eip_frontend" {
  count    = var.settings.omega_prd_frontend.count
  instance = aws_instance.omega_prd_frontend[count.index].id
  vpc      = true
  tags = {
    Name = "${var.eip_name_frontend}${count.index}"
  }
}

//Création instace EC2 omega_frontend

resource "aws_instance" "omega_prd_frontend" {
  ami                    = "ami-07e67bd6b5d9fd892"
  count                  = var.settings.omega_prd_frontend.count
  instance_type          = var.settings.omega_prd_frontend.instance_type
  key_name               = aws_key_pair.omega_prd_frontend_key_pair.key_name
  subnet_id              = aws_subnet.omega_prd_public_subnet[count.index].id
  vpc_security_group_ids = [aws_security_group.omega_prd_frontend_sg.id]
  tags = {
    Name = "prd_omega_frontend"
  }
}


# Définition des volumes EBS
resource "aws_ebs_volume" "omega_prd_front_vol" {
  availability_zone = "eu-west-3a"  
  size             = 5
  tags = {
    Name = "omega_prd_front_vol"
  }
}

resource "aws_ebs_volume" "omega_prd_back_vol" {
  availability_zone = "eu-west-3a"  
  size             = 5
  tags = {
    Name = "omega_prd_back_vol"
  }
}

# Rattacher le volume frontend a l instance frontend
resource "aws_volume_attachment" "attachment_frontend" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.omega_prd_front_vol.id
  count    = var.settings.omega_prd_frontend.count
  instance_id = aws_instance.omega_prd_frontend[count.index].id
  #instance_id = "i-0d6a26a23ddd316ca"
}

# Rattacher le volume backend a l instance backend
resource "aws_volume_attachment" "attachment_backend" {
  device_name = "/dev/sdb"
  volume_id   = aws_ebs_volume.omega_prd_back_vol.id
  count    = var.settings.omega_prd_backend.count
  instance_id = aws_instance.omega_prd_backend[count.index].id
}

#This file handles all the configuration for the backend data services
resource "aws_security_group" "bitso_backend_sg"{
	name = "bitso_frontend_sg"
	vpc_id = aws_vpc.prod-vpc.id
	
	#Ingress_for RDS Mysql
	ingress {
        	from_port = 3306
	        to_port = 3306
        	protocol = "tcp"
		#List of security group Group Names if using EC2
	        security_groups = ["${aws_security_group.bitso_frontend_sg.id}"]
	}

	ingress {
        	from_port = 22
	        to_port = 22
	        protocol = "tcp"
		#open to all VPC addresses
	        cidr_blocks = ["10.0.0.0/16"]
	}	
}

resource "aws_db_instance" "bitso_backend_rds" {
	#General options
	vpc_security_group_ids = ["${aws_security_group.bitso_backend_sg.id}"]
	db_subnet_group_name  = aws_subnet.bitso_priv_subnet.id
	availability_zone = "us-east-1a"

	#DB options
	allocated_storage    = 2
	#gp2 general purpose SSD
	storage_type         = "gp2"
	engine               = "mysql"
	engine_version       = "5.7"
	instance_class       = "db.t2.micro"
	name                 = "mydb"
	username             = "bitso"
	password             = "bitso_passwd"
	
}

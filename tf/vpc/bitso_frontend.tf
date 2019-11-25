#This is the file for the Public instances

#Security group for the frontend app
resource "aws_security_group" "bitso_frontend_sg" {
	name = "bitso_frontend_app"
	vpc_id = aws_vpc.prod-vpc.id

	tags={
        	Name = "bitso_frontend_app"
	}
	ingress {
	        from_port = 80
        	to_port = 80
	        protocol = "tcp"
	        cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
        	from_port = 443
	        to_port = 443
	        protocol = "tcp"
	        cidr_blocks = ["0.0.0.0/0"]
	}
	egress { # MySQL
	        from_port = 3306
        	to_port = 3306
	        protocol = "tcp"
        	cidr_blocks = ["10.0.1.0/24"]
	}

}

#Instance for the app frontend
resource "aws_instance" "bitso_frontend_app"{
	ami = "ami-01623d7b"
	availability_zone = "us-east-1a"
	instance_type = "m1.small"
	key_name = "bitso_aws_key"
	vpc_security_group_ids = ["${aws_security_group.bitso_frontend_sg.id}"]
	subnet_id = aws_subnet.bitso_pub_subnet.id
	associate_public_ip_address = true
	source_dest_check = false
}

#ElasticIp for the frontend instance
resource "aws_eip" "bitso_frontend_app" {
	instance = aws_instance.bitso_frontend_app.id
	vpc = true
}

#This file handles all the configuration for the backend data services
resource "aws_security_group" "bitso_backend_sg"{
	name = "bitso_frontend_sg"
	vpc_id = aws_vpc.prod-vpc.id
	
}

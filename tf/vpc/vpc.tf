#creating the VPC bitso_vpc
resource "aws_vpc" "prod-vpc" {
    cidr_block = "10.0.0.0/16"
    #getting an internal domain name
    enable_dns_support = "true"
    #getting an internal hostname
    enable_dns_hostnames = "true"
    tags ={
        Name = "bitso-vpc"
    }
}


#Internet GW 
resource "aws_internet_gateway" "gateway_bitso" {
	vpc_id = aws_vpc.prod-vpc.id
}


/*
Public resources
*/

resource "aws_subnet" "pub_app_subnet"{
	vpc_id = aws_vpc.prod-vpc.id
	cidr_block = "10.0.1.0/24"
	map_public_ip_on_launch = "true"
	tags= {
		    Name = "pub_app_subnet"
	}
}

resource "aws_route_table" "pub_route_table"{
	vpc_id = aws_vpc.prod-vpc.id
	route{
		cidr_block = "0.0.0./0"
		gateway_id = aws_internet_gateway.gateway_bitso.id
	}
	tags ={
		Name = "Subnet with public access"
	}
}


/*
Private resources
*/

resource "aws_subnet" "priv_db_subnet"{
vpc_id = aws_vpc.prod-vpc.id
cidr_block = "10.0.2.0/24"
map_public_ip_on_launch = "true"
tags= {
    Name = "priv_db_subnet"
}
}



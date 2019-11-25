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
 	tags ={
        Name = "bitso-igw"
	}
}


resource "aws_key_pair" "bitso_aws_key" {
  key_name   = "bitso_aws_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDNGzCJqDEThRhXPUY3uUO/mJWqlHkDsTUUin4yqSfu3rP0K751Fn2C0iIkCd0veAbSiSDhvp/cIhcRg5B4I57bHGNhfR7qT0gCJimmzplyj1elSW+5JLDBS+fEcBBiwTpx0jNUS6jzlwh+Ug1aA5VIqcSYgbdcIs6FKbFFjArIKL3ZFYBrTD6UbUGWiweBA5WOwbB3T25lUE/H5GOOR5Nlj8dxW+4fG+MOWQey41G8zcTMaA6ppRYobDgetmXxp2wSXa7l7vkrMS4gU7KH/xZDKFgFHi/dcD7rTlkRDPJf7R2jDJATxJNdh6cZ6znvfGKClfyWUWUXKlJRfijwSqM3 bmartinez@bernardo-Vvm"
}

#NAT SG
resource "aws_security_group" "bitso_nat_sg"{
	vpc_id = aws_vpc.prod-vpc.id
	name = "bitso_nat"
	description = "This Nat is to allow traffic to Private subnets"
	#ssh from within the VPC
	ingress{
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["10.0.0.0/16"]
	}
	ingress{
                from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
	egress {
		from_port = 22
                to_port = 22
                protocol = "tcp"
                cidr_blocks = ["10.0.0.0/16"]
	}
	#Web server access
	ingress {
        	from_port = 443
	        to_port = 443
	        protocol = "tcp"
	        cidr_blocks = ["0.0.0.0/0"]
	}
	
}

resource "aws_instance" "bitso_nat" {
    ami = "ami-01623d7b" 
    availability_zone = "us-east-1a"
    instance_type = "m1.small"
    key_name = "bitso_aws_key"
    vpc_security_group_ids = ["${aws_security_group.bitso_nat_sg.id}"]
    subnet_id = aws_subnet.bitso_pub_subnet.id
    associate_public_ip_address = true
    source_dest_check = false

    tags = {
        Name = "bitso_vpc_nat"
    }
}

resource "aws_eip" "bitso_nat_eip" {
    instance = aws_instance.bitso_nat.id
    vpc = true
}

/*
Section for the public resources
*/

resource "aws_subnet" "bitso_pub_subnet"{
	vpc_id = aws_vpc.prod-vpc.id
	cidr_block = "10.0.0.0/24"
	map_public_ip_on_launch = "true"
	tags= {
		    Name = "pub_app_subnet"
	}
}

resource "aws_route_table" "bitso_pub_route_table"{
	vpc_id = aws_vpc.prod-vpc.id
	route{
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.gateway_bitso.id
	}
	tags ={
		Name = "bitso_pub_subnet"
	}
}

resource "aws_route_table_association" "bitso_pub_assoc_route_table"{
	subnet_id = aws_subnet.bitso_pub_subnet.id
	route_table_id = aws_route_table.bitso_pub_route_table.id
}


/*
Section for the private resources, subnet, route table
*/

resource "aws_subnet" "bitso_priv_subnet"{
	vpc_id = aws_vpc.prod-vpc.id
	cidr_block = "10.0.1.0/24"
	map_public_ip_on_launch = "true"
	tags= {
	    Name = "bitso_priv_subnet"
	}
}

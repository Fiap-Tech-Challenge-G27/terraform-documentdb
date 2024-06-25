data "aws_vpc" "selected" {
  id = "vpc-0c9f3f1383a787786"
}

data "aws_subnet" "subnet1" {
  id = "subnet-0b298a2372a3b3439"
}

data "aws_subnet" "subnet2" {
  id = "subnet-049335028e498c087"
}
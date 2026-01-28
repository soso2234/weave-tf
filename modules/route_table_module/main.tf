//퍼블릭 라우팅 테이블 생성
resource "aws_route_table" "tf_pub_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "${var.pjt_name}_pub_rt"
  }
}

//퍼블릭 라우팅 테이블에 서브넷 연결
resource "aws_route_table_association" "tf_pub_rt_ass" {
  for_each = var.pub_subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.tf_pub_rt.id
}

//프라이빗 라우팅 테이블 생성
resource "aws_route_table" "tf_pri_rt" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.pjt_name}_pri_rt"
  }
}

//프라이빗 라우팅 테이블에 서브넷 연결
resource "aws_route_table_association" "tf_pri_rt_ass" {
  for_each = var.pri_subnets
  subnet_id      = each.value
  route_table_id = aws_route_table.tf_pri_rt.id
}

// EIP 생성
resource "aws_eip" "tf_nat_eip" {
  tags = {
    Name = "${var.pjt_name}_eip"
  }
}

// NAT 게이트웨이 생성
resource "aws_nat_gateway" "tf_nat_gw" {
  allocation_id = aws_eip.tf_nat_eip.id
  subnet_id     = var.public_subnet_id
  depends_on    = [aws_eip.tf_nat_eip]

  tags = {
    Name = "${var.pjt_name}_nat_gw"
  }
}

// 프라이빗 라우팅 테이블에 기본 경로 설정
resource "aws_route" "tf_pri_rt_route" {
  route_table_id         = aws_route_table.tf_pri_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.tf_nat_gw.id
  depends_on             = [aws_nat_gateway.tf_nat_gw]
}
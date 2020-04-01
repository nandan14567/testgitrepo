resource "aws_security_group" "del_security_group" {
  name        = var.security_group_name
  description = var.security_group_name
  vpc_id      = var.vpc_id
  tags        = {
    DCR: "AWS-WEBFALB0002-0.0.1"
  }

}

resource "aws_security_group_rule" "egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  description       = "All egress traffic"
  security_group_id = aws_security_group.del_security_group.id
}

resource "aws_security_group_rule" "tcp" {
  count             = var.tcp_ports == "default_null" ? 0 : length(split(",", var.tcp_ports))
  type              = "ingress"
  from_port         = element(split(",", var.tcp_ports), count.index)
  to_port           = 65535
  protocol          = "-1"
  cidr_blocks       = var.cidrs
  description       = "Ingress traffic"
  security_group_id = aws_security_group.del_security_group.id
}

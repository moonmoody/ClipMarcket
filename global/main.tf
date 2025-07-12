# Private instance ssm role
# iam 생성
resource "aws_iam_role" "ssm_role" {
  name        = "bastion-ssm-role"
  path        = "/"
  description = "Bastion Instance policy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "bastion-ssm-role"
  }
}

# iam에 역할 설정
resource "aws_iam_role_policy_attachment" "ssm_policy_att" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# instance에서 사용할 수 있게 해주는 설정.
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "bastion-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}
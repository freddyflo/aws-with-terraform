provider aws {
    region =  "eu-west-3"
}


# create IAM user
resource "aws_iam_user" "freddyflo-user" {
  name = "freddyflo"
  path = "/"

  tags = {
    tag-key = "terraform"
    "group" = "data.aws_iam_group.admin-group.group_name" 
  }
}


resource "aws_iam_access_key" "freddyflo-access-key" {
  user = aws_iam_user.freddyflo-user.name
}

resource "aws_iam_user_policy" "freddyflo_policy" {
  name = "freddyflo_policy"
  user = aws_iam_user.freddyflo-user.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "*",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# aws login profile   
resource "aws_iam_user_login_profile" "freddyflo-profile" {
  user    =  aws_iam_user.freddyflo-user.name
  pgp_key = "keybase:freddyflo"
}


# generated with keybase
output "password" {
  value = aws_iam_user_login_profile.freddyflo-profile.encrypted_password
}

# fetch existing group admin
data "aws_iam_group" "admin-group" {
  group_name = "admin"
}

# add user to group admin
resource "aws_iam_user_group_membership" "membership-admin" {
  user = aws_iam_user.freddyflo-user.name

  groups = [
    data.aws_iam_group.admin-group.group_name
  ]
}





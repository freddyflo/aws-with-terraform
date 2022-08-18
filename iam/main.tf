resource "aws_iam_user" "admin-user" {
    name = "terraform-user"
    tags = {
        Description = "Team Lead"
    }
}

resource "aws_iam_policy" "adminUser" {
    name = "AdminUsers"
    policy = jsonencode({
            Version: "2012-10-17",
            Statement: [
            {
                Sid: "Stmt1656492021990",
                Action: "*",
                Effect: "Allow",
                Resource: "*"
            }
        ]
    })
    # policy = file("admin-policy.json")
}

data "aws_iam_policy" "admin" {
    arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

data "aws_iam_group" "admin-group" {
    group_name = "admin"
}

resource "aws_iam_user_policy_attachment" "terraform-user-admin-access" {
    user = aws_iam_user.admin-user.name
    policy_arn = data.aws_iam_policy.admin.arn
}

resource "aws_iam_user_group_membership" "admin-membership" {
    user = aws_iam_user.admin-user.name

    groups = [
        data.aws_iam_group.admin-group.group_name
    ]
}


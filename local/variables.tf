variable "filename" {
  default = "/tmp/pets.txt"
}

variable "content" {
  default = "I love pets!"
}

variable "prefix" {
  default = "Mrs"
}

variable "separator" {
  default = "."
}

variable "length" {
  default = "1"
}

variable "file_permission" {
  default = "0700"
}

# variable "prefix" {
#     default = [ "Mr", "Mrs", "Sir" ]
#     type = list 0   1   2
# }

# variable file-content {
#     type = map
#     default = {
#         "statement1" = "We love pets!"
#         "statement2" = "We love animals"
#     }
# }
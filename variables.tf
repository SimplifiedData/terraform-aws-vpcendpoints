variable "tags" { type = any }
variable "environment" { type = string }
variable "endpoint_other" {
  type    = any
  default = {}
}
variable "security_group_rules_other" {
 type    = any
  default = {} 
}
#********************************************************************************#
#                      *-- Variable for resource Network --*                     #
#********************************************************************************#
variable "vpc_id" {
  type = string
}

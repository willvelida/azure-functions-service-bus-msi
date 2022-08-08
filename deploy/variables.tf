variable "location" {
  default = "australiaeast"
  type = string
  description = "The Azure location where all resources in this sample should be deployed to."
}

variable "role_definition_name" {
 type = string
 description = "The role assignment that this Function will have over Service Bus"
 default = "Azure Service Bus Data Owner"
}
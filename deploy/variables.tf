variable "location" {
  default = "australiaeast"
  type = string
  description = "The Azure location where all resources in this sample should be deployed to."
}

variable "owner_role" {
 type = string
 description = "The role assignment that this Function will have over Service Bus"
 default = "Azure Service Bus Data Owner"
}

variable "reader_role" {
 type = string
 description = "The role assignment that this Function will have over Service Bus"
 default = "Azure Service Bus Data Receiver"
}
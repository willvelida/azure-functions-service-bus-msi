variable "location" {
  default = "australiaeast"
  type = string
  description = "The Azure location where all resources in this sample should be deployed to."
}

variable "sender_role" {
 type = string
 description = "The sender role for Azure Service Bus"
 default = "Azure Service Bus Data Sender"
}

variable "reader_role" {
 type = string
 description = "The receiver role for Azure Service Bus"
 default = "Azure Service Bus Data Receiver"
}
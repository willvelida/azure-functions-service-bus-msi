terraform {
  required_version = ">=0.12"

  required_providers {
    azurerm = {
        source = "hashicorp/azurerm"
        version = "~>3.0"
    }
  } 
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

resource "random_integer" "ri" {
    min = 10000
    max = 99999
}

resource "azurerm_resource_group" "rg" {
  name = "sbmi${random_integer.ri.result}rg"
  location = var.location
}

resource "azurerm_storage_account" "stor" {
  name = "sbmi${random_integer.ri.result}storacc"
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_application_insights" "appins" {
    name = "sbmi${random_integer.ri.result}ai"
    resource_group_name = azurerm_resource_group.rg.name
    location = azurerm_resource_group.rg.location
    application_type = "web"
}

resource "azurerm_servicebus_namespace" "sbnamespace" {
    name = "sbmi${random_integer.ri.result}sb"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku = "Standard"
    identity {
      type = "SystemAssigned"
    }
}

resource "azurerm_servicebus_queue" "ordersqueue" {
  name = "ordersqueue"
  namespace_id = azurerm_servicebus_namespace.sbnamespace.id
}

resource "azurerm_service_plan" "asp" {
    name = "sbmi${random_integer.ri.result}asp"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    os_type = "Windows"
    sku_name = "Y1"
}

resource "azurerm_windows_function_app" "funcapp" {
    name = "sbmi${random_integer.ri.result}fa"
    location = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    service_plan_id = azurerm_service_plan.asp.id
    storage_account_name = azurerm_storage_account.stor.name
    storage_account_access_key = azurerm_storage_account.stor.primary_access_key
    app_settings = {
      "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.appins.instrumentation_key}"
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = "InstrumentationKey=${azurerm_application_insights.appins.instrumentation_key};IngestionEndpoint=https://australiaeast-1.in.applicationinsights.azure.com/;LiveEndpoint=https://australiaeast.livediagnostics.monitor.azure.com/"
      "QueueName" = "${azurerm_servicebus_queue.ordersqueue.name}"
      "ServiceBusConnection__fullyQualifiedNamespace" = "${azurerm_servicebus_namespace.sbnamespace.name}.servicebus.windows.net"
      "ServiceBusEndpoint" = "${azurerm_servicebus_namespace.sbnamespace.name}.servicebus.windows.net"
    }
    site_config {
      application_insights_connection_string = azurerm_servicebus_namespace.sbnamespace.name
    }

    identity {
      type = "SystemAssigned"
    }
}

resource "azurerm_role_assignment" "sbrole" {
    scope = azurerm_servicebus_namespace.sbnamespace.id
    role_definition_name = var.owner_role
    principal_id = azurerm_windows_function_app.funcapp.identity.0.principal_id
}

resource "azurerm_role_assignment" "sbreaderrole" {
  scope = azurerm_servicebus_namespace.sbnamespace.id
    role_definition_name = var.reader_role
    principal_id = azurerm_windows_function_app.funcapp.identity.0.principal_id
}
# Using Managed Identites with Azure Functions and Service Bus

This sample demonstrates how to configure System Assigned Identities to authenticate to Service Bus via an Azure Function. The infrastructure is provisioned with Terraform and the Function is built using C#.

This sample uses Dependency Injection and a Service Bus trigger to interact with Service Bus. With this in mind, you will need to configure two different App Settings using the Service Bus namespace endpoint with different names to avoid the Service Bus trigger from starting up. For example, in the Startup.cs file we use a the following:

```csharp
builder.Services.AddSingleton(sp =>
{
    IConfiguration config = sp.GetRequiredService<IConfiguration>();
    return new ServiceBusClient(config["ServiceBusEndpoint"], new DefaultAzureCredential());
});
```

In our trigger, we use the following:

```csharp
[FunctionName(nameof(ProcessOrderFromQueue))]
public void Run([ServiceBusTrigger("ordersqueue", Connection = "ServiceBusConnection")] string myQueueItem)
{
    // Code here
}
```

To use MSI with a Service Bus Trigger, we need to configure the following app setting:

```json
{
    "ServiceBusConnection__fullyQualifiedNamespace": "<namespace>.servicebus.windows.net", // Use for Service Bus Trigger
    "ServiceBusEndpoint": "<namespace>.servicebus.windows.net" // Use for DI Client
}
```

## Deploying the sample

1. Clone the repository.
1. In a terminal, navigate to the deploy folder and run ``terraform apply``.
1. Open the Function App in Visual Studio and deploy to your Function App in Azure.
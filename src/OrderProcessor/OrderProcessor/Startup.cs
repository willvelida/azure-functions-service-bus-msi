using Azure.Identity;
using Azure.Messaging.ServiceBus;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using OrderProcessor;
using System.IO;

[assembly: FunctionsStartup(typeof(Startup))]
namespace OrderProcessor
{
    public class Startup : FunctionsStartup
    {
        public override void Configure(IFunctionsHostBuilder builder)
        {
            var configuration = new ConfigurationBuilder()
                .SetBasePath(Directory.GetCurrentDirectory())
                .AddJsonFile("local.settings.json", true, true)
                .AddEnvironmentVariables()
                .Build();

            builder.Services.AddLogging();
            builder.Services.AddSingleton<IConfiguration>(configuration);
            builder.Services.AddSingleton(sp =>
            {
                IConfiguration config = sp.GetRequiredService<IConfiguration>();
                return new ServiceBusClient(config["ServiceBusConnection"], new DefaultAzureCredential());
            });
        }
    }
}

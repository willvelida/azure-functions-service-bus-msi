using Azure.Messaging.ServiceBus;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;
using System.Threading.Tasks;

namespace OrderProcessor.Functions
{
    public class SendOrderToQueue
    {
        private readonly ServiceBusClient _serviceBusClient;
        private readonly IConfiguration _configuration;
        private readonly ServiceBusSender _serviceBusSender;
        private readonly ILogger<SendOrderToQueue> _logger;

        public SendOrderToQueue(ServiceBusClient serviceBusClient, ILogger<SendOrderToQueue> logger, IConfiguration configuration)
        {
            _serviceBusClient=serviceBusClient;
            _configuration=configuration;
            _serviceBusSender = _serviceBusClient.CreateSender(_configuration["QueueName"]);
            _logger=logger;
        }

        [FunctionName(nameof(SendOrderToQueue))]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "post", Route = "sendmessage")] HttpRequest req)
        {
            try
            {
                Order order = new Order() { OrderId = Guid.NewGuid().ToString() };

                _logger.LogInformation($"Sending Order ID: {order.OrderId} to queue");

                await _serviceBusSender.SendMessageAsync(new ServiceBusMessage(JsonConvert.SerializeObject(order)));

                return new OkObjectResult(order);
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(SendOrderToQueue)}: {ex.Message}");
                throw;
            }
        }
    }
}

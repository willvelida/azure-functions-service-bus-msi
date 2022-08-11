using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using System;

namespace OrderProcessor.Functions
{
    public class ProcessOrderFromQueue
    {
        private readonly ILogger<ProcessOrderFromQueue> _logger;

        public ProcessOrderFromQueue(ILogger<ProcessOrderFromQueue> logger)
        {
            _logger=logger;
        }

        [FunctionName(nameof(ProcessOrderFromQueue))]
        public void Run([ServiceBusTrigger("ordersqueue", Connection = "ServiceBusConnection")] string myQueueItem)
        {
            try
            {
                _logger.LogInformation($"Receiving message: {myQueueItem}");
            }
            catch (Exception ex)
            {
                _logger.LogError($"Exception thrown in {nameof(ProcessOrderFromQueue)}: {ex.Message}");
                throw;
            }
        }
    }
}

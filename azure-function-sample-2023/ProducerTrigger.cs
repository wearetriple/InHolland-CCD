using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace azure_function_sample_2023
{
    public static class ProducerTrigger
    {
        [FunctionName("ProducerTrigger")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
            [Queue("myqueue-items")] ICollector<string> queueItemCollector,
            ILogger log)
        {
            string message = req.Query["msg"];

            if (string.IsNullOrEmpty(message))
            {
                message = "EMPTY MESSAGE";
            }

            queueItemCollector.Add(message);

            return new OkObjectResult(new {
                Input = message,
                Message = "Added to queue"
            });
        }
    }
}

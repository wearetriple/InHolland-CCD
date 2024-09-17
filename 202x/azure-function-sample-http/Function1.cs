using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;

namespace azure_function_sample_http
{
    public static class Function1
    {
        // endpoint of function is https://{function app name}.azurewebsites.net/api/{function name}
        [FunctionName("Function1")]
        public static async Task<IActionResult> Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req, ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            var element1 = req.Query["el1"];
            var element2 = req.Query["el2"];

            if (int.TryParse(element1, out var value1) && int.TryParse(element2, out var value2))
            {
                return new OkObjectResult(new ResponseModel
                {
                    Result = value1 * value2
                });
            }
            else
            {
                return new BadRequestObjectResult(new ResponseModel
                {
                    Error = true,
                    Message = "Use the query parameters el1, and el2 to create a valid request."
                });
            }
        }
    }
}

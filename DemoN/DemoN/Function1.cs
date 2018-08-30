using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.Extensions.Logging;

namespace DemoN
{
    public static class Function1
    {
        // endpoint of function is https://{function app name}.azurewebsites.net/api/{function name}
        [FunctionName("Function1")]
        public static IActionResult Run([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)]HttpRequest req, ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            var element1 = req.Query["el1"];
            var element2 = req.Query["el2"];

            if (int.TryParse(element1, out var value1) && int.TryParse(element2, out var value2))
            {
                return new OkObjectResult(value1 * value2);
            }
            else
            {
                return new BadRequestResult();
            }
        }
    }
}

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;

namespace DesignPatternsTargetFunctionApp;

public class Function1
{
    private static int _executionCount = 0;

    [Function("Function1")]
    public static async Task<IActionResult> RunAsync([HttpTrigger(AuthorizationLevel.Anonymous, "get")] HttpRequest req)
    {
        if (++_executionCount % 11 > 5)
        {
            await Task.Delay(3000);
            return new JsonResult(new { ImDead = true })
            {
                StatusCode = 500
            };
        }
        else
        {
            return new JsonResult(new { ImOk = true });
        }
    }
}

using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.Functions.Worker;
using Microsoft.Extensions.Logging;

namespace DemoFunctionApp;

public class Function1
{
    private readonly ILogger<Function1> _logger;

    public Function1(ILogger<Function1> logger)
    {
        _logger = logger;
    }

    [Function("Function1")]
    public IActionResult Run1([HttpTrigger(AuthorizationLevel.Anonymous, "get", "post")] HttpRequest req)
    {
        _logger.LogInformation("C# HTTP trigger function processed a request.");
        return new OkObjectResult("Welcome to Azure Functions!");
    }

    internal record RequestBody(int Number);

    [Function("Function2")]
    public async Task Run2Async([HttpTrigger(AuthorizationLevel.Anonymous, "post")] HttpRequest req)
    {
        _logger.LogInformation("C# HTTP trigger function processed a request.");

        var body = await req.ReadFromJsonAsync<RequestBody>();

        var semaphore = new SemaphoreSlim(1);

        await Task.WhenAll(
            Enumerable.Range(0, body?.Number ?? 10)
                .Select(async i =>
                {
                    await Task.Delay(1);

                    await semaphore.WaitAsync();
                    await req.HttpContext.Response.WriteAsync($"This is part {i}\r\n");

                    semaphore.Release();
                }));

    }
}

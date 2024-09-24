using Microsoft.Extensions.Hosting;

namespace DesignPatternsClient;

public class ForegroundService : BackgroundService
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly Uri _uri;

    public ForegroundService(
        IHttpClientFactory httpClientFactory)
    {
        _httpClientFactory = httpClientFactory;
        _uri = new Uri("http://localhost:7080/api/Function1");
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        Console.WriteLine("Policy demos!");
        Console.WriteLine("Start with vanilla client?");

        Console.ReadLine();

        await DoRequestsAsync(_httpClientFactory.CreateClient("vanilla"), 10);

        Console.WriteLine();
        Console.WriteLine("Start with retry client?");

        Console.ReadLine();

        await DoRequestsAsync(_httpClientFactory.CreateClient("retry"), 10);

        Console.WriteLine();
        Console.WriteLine("Start with circuit breaker client?");

        Console.ReadLine();

        await DoRequestsAsync(_httpClientFactory.CreateClient("circuitBreaker"), 10);
    }

    private async Task DoRequestsAsync(HttpClient client, int repeat)
    {
        for (var i = 0; i < repeat; i++)
        {
            Console.WriteLine($"Request {i + 1}");

            try
            {
                var response = await client.GetAsync(_uri);

                Console.WriteLine($"HTTP: {response.StatusCode}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"EXCEPTION: {ex.Message}");

            }

            await Task.Delay(500);
        }
    }
}

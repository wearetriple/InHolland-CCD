using DesignPatternsClient;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Polly;
using Polly.Extensions.Http;

var builder = new HostBuilder();

builder.ConfigureServices(services =>
{
    services.AddHostedService<ForegroundService>();

    services.AddHttpClient("vanilla");

    var retry = HttpPolicyExtensions
        .HandleTransientHttpError()
        .RetryAsync(6);

    services.AddHttpClient("retry").AddPolicyHandler(retry);

    var circuitBreaker = HttpPolicyExtensions
        .HandleTransientHttpError()
        .CircuitBreakerAsync(1, TimeSpan.FromSeconds(2));

    services.AddHttpClient("circuitBreaker").AddPolicyHandler(circuitBreaker);
});

var host = builder.Build();

await host.RunAsync();

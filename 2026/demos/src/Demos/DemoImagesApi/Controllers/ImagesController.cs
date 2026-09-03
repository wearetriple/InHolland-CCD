using Azure.Identity;
using Azure.Storage.Blobs;
using Azure.Storage.Sas;
using Microsoft.AspNetCore.Mvc;

namespace DemoImagesApi.Controllers;

[ApiController]
[Route("images")]
public class ImagesController : ControllerBase
{
    private readonly IConfiguration _configuration;
    private readonly ILogger<ImagesController> _logger;

    public ImagesController(IConfiguration configuration, ILogger<ImagesController> logger)
    {
        _configuration = configuration;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<string>>> Get(CancellationToken cancellationToken)
    {
        var accountName = _configuration["STORAGE_ACCOUNT_NAME"];
        var containerName = _configuration["BLOB_CONTAINER_NAME"] ?? "images";

        if (string.IsNullOrWhiteSpace(accountName))
        {
            return Problem("STORAGE_ACCOUNT_NAME is not set.");
        }

        var serviceClient = new BlobServiceClient(
            new Uri($"https://{accountName}.blob.core.windows.net"),
            new DefaultAzureCredential());

        var container = serviceClient.GetBlobContainerClient(containerName);

        var expiresOn = DateTimeOffset.UtcNow.AddHours(1);
        var userDelegationKey = await serviceClient.GetUserDelegationKeyAsync(
            DateTimeOffset.UtcNow.AddMinutes(-5),
            expiresOn,
            cancellationToken);

        var urls = new List<string>();

        await foreach (var blob in container.GetBlobsAsync(cancellationToken: cancellationToken))
        {
            var sas = new BlobSasBuilder
            {
                BlobContainerName = containerName,
                BlobName = blob.Name,
                Resource = "b",
                StartsOn = DateTimeOffset.UtcNow.AddMinutes(-5),
                ExpiresOn = expiresOn
            };
            sas.SetPermissions(BlobSasPermissions.Read);

            var blobClient = container.GetBlobClient(blob.Name);
            urls.Add($"{blobClient.Uri}?{sas.ToSasQueryParameters(userDelegationKey, accountName)}");
        }

        _logger.LogInformation("Listed {Count} blobs from {Container}.", urls.Count, containerName);

        return Ok(urls);
    }
}

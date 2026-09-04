using Azure.Storage.Blobs;
using Azure.Storage.Sas;
using Microsoft.AspNetCore.Mvc;

namespace DemoImagesApi.Controllers;

[ApiController]
[Route("images")]
public class ImagesController : ControllerBase
{
    private readonly BlobServiceClient _blobs;
    private readonly IConfiguration _configuration;
    private readonly ILogger<ImagesController> _logger;

    public ImagesController(
        BlobServiceClient blobs,
        IConfiguration configuration,
        ILogger<ImagesController> logger)
    {
        _blobs = blobs;
        _configuration = configuration;
        _logger = logger;
    }

    [HttpGet]
    public async Task<ActionResult<IReadOnlyList<string>>> Get(CancellationToken cancellationToken)
    {
        var containerName = _configuration["BLOB_CONTAINER_NAME"] ?? "images";
        var container = _blobs.GetBlobContainerClient(containerName);
        await container.CreateIfNotExistsAsync(cancellationToken: cancellationToken);

        var expiresOn = DateTimeOffset.UtcNow.AddHours(1);
        var urls = new List<string>();

        await foreach (var blob in container.GetBlobsAsync(cancellationToken: cancellationToken))
        {
            var blobClient = container.GetBlobClient(blob.Name);
            urls.Add(await CreateReadUrlAsync(blobClient, containerName, blob.Name, expiresOn, cancellationToken));
        }

        _logger.LogInformation("Listed {Count} blobs from {Container}.", urls.Count, containerName);

        return Ok(urls);
    }

    private async Task<string> CreateReadUrlAsync(
        BlobClient blobClient,
        string containerName,
        string blobName,
        DateTimeOffset expiresOn,
        CancellationToken cancellationToken)
    {
        if (blobClient.CanGenerateSasUri)
        {
            return blobClient.GenerateSasUri(BlobSasPermissions.Read, expiresOn).ToString();
        }

        var userDelegationKey = await _blobs.GetUserDelegationKeyAsync(
            DateTimeOffset.UtcNow.AddMinutes(-5),
            expiresOn,
            cancellationToken);

        var sas = new BlobSasBuilder
        {
            BlobContainerName = containerName,
            BlobName = blobName,
            Resource = "b",
            StartsOn = DateTimeOffset.UtcNow.AddMinutes(-5),
            ExpiresOn = expiresOn
        };
        sas.SetPermissions(BlobSasPermissions.Read);

        return $"{blobClient.Uri}?{sas.ToSasQueryParameters(userDelegationKey, _blobs.AccountName)}";
    }
}

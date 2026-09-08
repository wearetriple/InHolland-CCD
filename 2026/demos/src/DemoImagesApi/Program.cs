using Azure.Identity;
using Azure.Storage.Blobs;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddSingleton(CreateBlobServiceClient(builder.Configuration));

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.MapControllers();
app.Run();

static BlobServiceClient CreateBlobServiceClient(IConfiguration configuration)
{
    var connectionString = configuration.GetConnectionString("Storage");
    if (!string.IsNullOrWhiteSpace(connectionString))
    {
        return new BlobServiceClient(connectionString);
    }

    var accountName = configuration["STORAGE_ACCOUNT_NAME"];
    if (string.IsNullOrWhiteSpace(accountName))
    {
        throw new InvalidOperationException(
            "Set ConnectionStrings:Storage (Azurite) or STORAGE_ACCOUNT_NAME (Azure).");
    }

    return new BlobServiceClient(
        new Uri($"https://{accountName}.blob.core.windows.net"),
        new DefaultAzureCredential());
}

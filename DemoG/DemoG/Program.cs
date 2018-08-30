using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Blob;
using Microsoft.WindowsAzure.Storage.Queue;
using System;
using System.IO;
using System.Threading.Tasks;

namespace DemoG
{
    class Program
    {
        static async Task Main(string[] args)
        {
            var storageAccount = CloudStorageAccount.Parse("--insertkey--");

            {
                var client = storageAccount.CreateCloudBlobClient();

                var container = client.GetContainerReference("somecontainer");
                await container.CreateIfNotExistsAsync();
                await container.SetPermissionsAsync(new BlobContainerPermissions { PublicAccess = BlobContainerPublicAccessType.Blob });

                var blobName = $"{Guid.NewGuid().ToString()}.jpg";

                var blob = container.GetBlockBlobReference(blobName);

                var fileStream = File.OpenRead("trash.jpg");

                await blob.UploadFromStreamAsync(fileStream);
            }

            {
                var client = storageAccount.CreateCloudQueueClient();

                var queue = client.GetQueueReference("somequeue");
                await queue.CreateIfNotExistsAsync();

                do
                {
                    var message = Guid.NewGuid().ToString();
                    
                    await queue.AddMessageAsync(new CloudQueueMessage(message));

                    await Task.Delay(1000);

                } while (true);
            }
        }
    }
}

using System;
using System.Threading.Tasks;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;
using Microsoft.WindowsAzure.Storage;
using Microsoft.WindowsAzure.Storage.Queue;

namespace DemoJ
{
    public static class Function1
    {
        [FunctionName("Function1")]
        public static async Task RunAsync([TimerTrigger("*/1 * * * * *")]TimerInfo myTimer, ILogger log)
        {
            var storageAccount = CloudStorageAccount.Parse("--insert-key--");

            var client = storageAccount.CreateCloudQueueClient();

            var queue = client.GetQueueReference("somequeue");
            await queue.CreateIfNotExistsAsync();

            var message = Guid.NewGuid().ToString();

            await queue.AddMessageAsync(new CloudQueueMessage(message));
        }
    }
}

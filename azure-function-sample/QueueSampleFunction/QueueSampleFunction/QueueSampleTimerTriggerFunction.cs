/*
 * Queue in function documentation
 * https://docs.microsoft.com/en-us/azure/azure-functions/functions-bindings-storage-queue
 */


using System;
using Microsoft.Azure.Storage.Queue;
using Microsoft.Azure.WebJobs;
using Microsoft.Extensions.Logging;

namespace QueueSampleFunction
{
    public static class QueueSampleTimerTriggerFunction
    {
        [FunctionName("QueueSampleTimerTriggerFunction")]
        public static void Run([TimerTrigger("0 */1 * * * *")]TimerInfo myTimer, ILogger log, [Queue("sample-queue")] CloudQueue queue)
        {
            if (queue.CreateIfNotExists()) {
                log.LogInformation($"Queue created");
            }

            var queueMsg = new CloudQueueMessage($"MsgForQueue at {DateTime.Now}");

            queue.AddMessage(queueMsg);

            log.LogInformation($"C# Timer trigger function executed at: {DateTime.Now}");
        }
    }
}

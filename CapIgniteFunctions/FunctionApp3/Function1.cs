using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Azure.Documents;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Host;
using Microsoft.Extensions.Logging;

namespace FunctionApp3
{
    public class TempItem
    {
        public string Description { get; set; }
        public bool IsCompleted { get; set; }
    }

    public static class Function1
    {
        [FunctionName("Function1")]
        public static async Task Run(
            [CosmosDBTrigger(
                databaseName: "Tasks",
                collectionName: "Items",
                ConnectionStringSetting = "ConnectionString",
                LeaseCollectionName = "leases", 
                CreateLeaseCollectionIfNotExists = true)]IReadOnlyList<Document> input,
            [CosmosDB(
                databaseName: "Tasks",
                collectionName: "FinishedItems",
                ConnectionStringSetting = "ConnectionString")]
            IAsyncCollector<TempItem> toDoItemsOut,
            ILogger log)
        {
            if (input != null && input.Count > 0)
            {
                log.LogInformation("Documents modified " + input.Count);
                log.LogInformation("First document Id " + input[0].Id);

                foreach (dynamic document in input)
                {
                    if (document.isComplete)
                    {
                        await toDoItemsOut.AddAsync(new TempItem
                        {
                            Description = document.description,
                            IsCompleted = document.isComplete
                        });
                    }
                }
            }
        }
    }
}

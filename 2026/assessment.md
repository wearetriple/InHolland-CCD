# Azure + GitHub assignment

## Task Requirements

Using azure container apps, create an app that exposes an HTTP endpoint that starts an image creation process and returns a unique id for that process. This id can be used to either fetch the status of the running process, or the results of the completed process. The results will be a list of links to each generated image. These images are served from blob storage.

The image creation process consists of multiple jobs. The first job fetches data for 50 weather stations. For each weather station, a separate job should be run to grab a public image and add the weather data to that image, in a fan-out fashion. After the image has its weather data, the job should store it in the blob storage.

A sample of code for writing text on an image can be found here.
<https://github.com/wearetriple/InHolland-CCD/tree/master/2026/samples/ImageEditor>

## Must

- Expose publicly accessible API for requesting a set of fresh images with current weather data.
- Employ queues to process the jobs in the background so the initial call stays fast.
- Employ Blob Storage to store all generated images and to expose the files.
- Employ Queue Storage to create and read (+ delete) messages from the queue.
- Employ Buienrader api to get weather station data <https://data.buienradar.nl/2.0/feed/json>
- Employ any public api for retrieving an image to write the weather data on. e.g. <https://unsplash.com/developers>
- Expose a publicly accessible API for fetching the generated images.
- Provide HTTP files as API documentation.
- Create a fitting Bicep template (include the queues as well).
- Add all files to GitHub repo and add Hijdra (<https://github.com/Hijdra>) or <mark.hijdra@wearetriple.com> to organization and project.
- Create a deploy.ps1 script that publishes your code using the dotnet cli, creates the resources in azure using the Bicep template and deploys the function using the azure cli.
- Employ **multiple** queues, one for starting the job and one for fetching and updating an image.
- Deploy the code to azure and have a working endpoint.

## Could

- Use SAS token instead of publicly accessible blob storage for fetching finished image directly from Blob.
- Build and deploy the code automatically from GitHub.
- Use authentication on request API. (Be sure to provide me with credentials)
- Provide a status endpoint for fetching progress status and saving status in Table.

Having all **Must** requirements will result in a minimal passing grade, also having **Could** requirements results in a higher grade.

Deadline: Friday 6 November 09:00 AM CET

Please inform me that you finished the assignment by mailing to <mark.hijdra@wearetriple.com>

Also include the link to the correct repository.

Do not use that mailbox for questions, as that mailbox is not read regularly.

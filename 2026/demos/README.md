# Demos (2026)

**.NET 10** API for Azure Container Apps, used with [`../student-material/`](../student-material/) and [Lab 3](../labs/03-deploy-image.md).

Open `src/Demos.slnx`. Requires the [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0).

| Project | Purpose |
| --- | --- |
| `DemoImagesApi` | `GET /images` — short-lived SAS URLs for blobs in the `images` container |

Local: start Azurite, then `https://localhost:7060`. Development uses `UseDevelopmentStorage=true` (see `appsettings.Development.json`). In Azure, Bicep sets `STORAGE_ACCOUNT_NAME` and the app uses the Container App identity.

```powershell
docker compose -f src/DemoImagesApi/docker-compose.yml up -d
dotnet run --project src/DemoImagesApi --launch-profile https
```

Dockerfile listens on port **8080**. Push as `api:latest` (see Lab 3). HTTP sample: [`http/images-api.http`](http/images-api.http).

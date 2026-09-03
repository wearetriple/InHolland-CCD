# Demos (2026)

**.NET 10** API for Azure Container Apps, used with [`../student-material/`](../student-material/) and [Lab 3](../labs/03-deploy-image.md).

Open `src/Demos/Demos.slnx`. Requires the [.NET 10 SDK](https://dotnet.microsoft.com/download/dotnet/10.0).

| Project | Purpose |
| --- | --- |
| `DemoImagesApi` | `GET /images` — short-lived SAS URLs for blobs in the `images` container |

Local: `http://localhost:5060` (`az login`; `STORAGE_ACCOUNT_NAME=inhccdlab2stg<suffix>`). In Azure, the Container App identity and env vars come from Bicep.

Dockerfile listens on port **8080**. Push as `api:latest` (see Lab 3). HTTP sample: [`http/images-api.http`](http/images-api.http).

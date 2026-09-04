# Student Bicep starter (2026)

Three templates, same `namePrefix` as the labs (for example `mh26`).

## Login into Azure

Login into Azure using

``
az login
``

## Resource group

```powershell
$env:SUFFIX = "mh26"
$env:LOCATION = "westeurope"
$env:RG = "inh-ccd-lab2-$($env:SUFFIX)"
az group create -n $env:RG -l $env:LOCATION
```

## Container App + Storage

Azure **Container App** (quickstart image) plus a **Storage** account with a private `images` blob container.

```powershell
az deployment group create `
  -g $env:RG `
  -f basic.bicep `
  --parameters "namePrefix=$($env:SUFFIX)"
```

| Resource | Name |
| --- | --- |
| Container App | `inh-ccd-lab2-app-<suffix>` |
| Container Apps environment | `inh-ccd-lab2-env-<suffix>` |
| Log Analytics workspace | `inh-ccd-lab2-law-<suffix>` |
| Storage account | `inhccdlab2stg<suffix>` |
| Blob container | `images` (private) |

The Container App has a **system-assigned managed identity** and **Storage Blob Data Reader** on the storage account. Environment variables `STORAGE_ACCOUNT_NAME` and `BLOB_CONTAINER_NAME` are set for the demo API. Do not put account keys in Bicep or Git.

A matching API is `2026/demos/src/DemoImagesApi` (`GET /images`). Push it to ACR as `api:latest`, then deploy `container-app-image.bicep`.

## Container Registry

Separate template so you can add **ACR** when you start pushing your own images. Admin user is **off** — pull and push with identity (or `az acr login`), not a registry password in Git.

```powershell
az deployment group create `
  -g $env:RG `
  -f registry.bicep `
  --parameters "namePrefix=$($env:SUFFIX)"
```

| Resource | Name |
| --- | --- |
| Container Registry | `inhccdlab2acr<suffix>` (Basic SKU) |
| User-assigned identity | `inh-ccd-lab2-id-<suffix>` (**AcrPull**) |

Grant **AcrPush** separately to whatever builds images (for example a GitHub Actions identity).

## Point the Container App at your image

Deploy **after** `basic.bicep`, `registry.bicep`, and pushing an image (for example `api:latest`) to ACR. Admin user stays off; the app pulls with the user-assigned identity from `registry.bicep`.

.NET containers usually listen on port **8080** (the quickstart image used port 80).

```powershell
az deployment group create `
  -g $env:RG `
  -f container-app-image.bicep `
  --parameters "namePrefix=$($env:SUFFIX)" imageRepository=api imageTag=latest targetPort=8080
```

## GitHub Actions (build)

Copy `.github/workflows/build.yml` to the **root** of your GitHub repo (Actions only reads that path). Point `env.PROJECT` at your `.csproj` or `.sln`. Default is `DemoImagesApi/DemoImagesApi.csproj` (copy that project from `2026/demos/src/DemoImagesApi`).

The workflow restores and builds on push to `main`, pull requests, and manual **Run workflow**. It does not deploy.

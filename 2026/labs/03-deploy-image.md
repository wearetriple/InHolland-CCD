# Lab 3 — Deploy image

This lab continues **Lab 2**. Same suffix and resource group. `basic.bicep` must already be deployed.

Starter files: [`../student-material/`](../student-material/).  
API: [`../demos/src/DemoImagesApi`](../demos/src/DemoImagesApi) (`GET /images`).

## Before you start

- [Lab 2](02-bicep.md) complete (resource group, Container App, storage)
- Azure CLI logged in: `az login`
- Docker running

Reuse the Lab 2 variables:

```powershell
$env:SUFFIX = "mh26"
$env:LOCATION = "westeurope"
$env:RG = "inh-ccd-lab2-$($env:SUFFIX)"
```

| What | Example |
| --- | --- |
| Container Registry | `inhccdlab2acrmh26` |
| Image | `inhccdlab2acrmh26.azurecr.io/api:latest` |

Run Bicep commands from `2026/student-material` (or pass full `-f` paths).

## Create the registry

Admin user stays **off**. You push with `az acr login` (your Azure identity), not a registry password. This template also creates a **user-assigned identity** and grants it **AcrPull**.

```powershell
az deployment group create `
  -g $env:RG `
  -f registry.bicep `
  --parameters "namePrefix=$($env:SUFFIX)"
```

## Build and push the demo API

Build context must be the **DemoImagesApi** folder (the Dockerfile copies `DemoImagesApi.csproj` from `.`).

```powershell
$acr = "inhccdlab2acr$($env:SUFFIX)"
$loginServer = "$acr.azurecr.io"

az acr login -n $acr

Set-Location <path-to-workshop>/2026/demos/src/DemoImagesApi
docker build -t "$loginServer/api:latest" .
docker push "$loginServer/api:latest"
```

Contributor on the resource group is enough to push in this lab. Building the image also gives **AcrPull** time to propagate.

## Point the Container App at the image

.NET listens on port **8080** (the quickstart image used 80). The app keeps its system-assigned identity for Storage, and uses the pull identity from `registry.bicep` for ACR.

```powershell
Set-Location <path-to-workshop>/2026/student-material

az deployment group create `
  -g $env:RG `
  -f container-app-image.bicep `
  --parameters "namePrefix=$($env:SUFFIX)" imageRepository=api imageTag=latest targetPort=8080
```

If a role assignment already exists from `basic.bicep`, that is fine.

## Check the API

Wait about a minute for RBAC, then open Application Url + `/images`, or use [`../demos/http/images-api.http`](../demos/http/images-api.http).

You should get a JSON array of SAS URLs. `[]` means the app works but the `images` container is empty — upload a blob in the portal (same as Lab 1).

The GitHub **build** workflow only compiles the project. It does not push the image or run these deploys.

## Troubleshooting

| Problem | What to try |
| --- | --- |
| Image pull failed / Managed identity | Redeploy `registry.bicep`, wait a minute, then `container-app-image.bicep`. Confirm `docker push` used `api:latest`. |
| App stuck in **Failed** | Redeploy `basic.bicep` to restore the quickstart image, then `registry.bicep`, then `container-app-image.bicep`. |
| `/images` 500 or `CreateIfNotExists` / 403 | Reader cannot create containers. Use an image that only lists blobs; confirm `images` exists from `basic.bicep`. |
| Still the quickstart welcome page | `container-app-image.bicep` not applied, or target port still 80 |
| `docker push` denied | `az login` / `az acr login`; you need push rights on the RG |

## Cleanup

Same as Lab 2: delete resource group `inh-ccd-lab2-<suffix>` when you are finished with both labs.

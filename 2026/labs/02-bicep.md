# Lab 2 — Bicep

Starter files: [`../student-material/`](../student-material/).

## Before you start

- Lab 1 complete
- Azure CLI `az` installed

Reuse your suffix (for example your initials + day): `mh26`

## Set environment variables

```powershell
$env:SUFFIX = "mh26"
$env:LOCATION = "westeurope"
$env:RG = "inh-ccd-lab2-$($env:SUFFIX)"
```

## Login into Azure

```powershell
az login
```

## Resource group

```powershell
az group create -n $env:RG -l $env:LOCATION
```

## Container App + Storage

Azure **Container App** (quickstart image) plus a **Storage** account with a private `images` blob container.

Run from `2026/student-material` (or pass a full `-f` path):

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

Continue with [Lab 3 — Deploy image](03-deploy-image.md) to add ACR and run `DemoImagesApi`.

## Cleanup awareness

Do **not** delete yet if you continue into Lab 3.

Otherwise:

1. Open **Resource groups** → `inh-ccd-lab2-<suffix>`.
2. Select **Delete resource group**.
3. Type the resource group name to confirm, then **Delete**.

Deleting the group removes the Container App, environment, and storage account together.

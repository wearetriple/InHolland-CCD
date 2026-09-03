# Lab 1 — Container App and Storage (Azure Portal)

# Before you start

- Logged into [Azure Portal](https://portal.azure.com)
- Correct **directory** and **subscription** selected (top-right)

Pick a unique suffix (for example your initials + day): `mh26`

| What | Example |
| --- | --- |
| Suffix | `mh26` |
| Region | **West Europe** |
| Resource group | `inh-ccd-lab1-mh26` |
| Container App | `inh-ccd-app-mh26` |
| Container Apps environment | `inh-ccd-env-mh26` |
| Storage account | `inhccdlab1stgmh26` (3–24 characters, **lowercase letters and numbers only**) |

## What good looks like (checkpoints)

| # | Checkpoint |
| --- | --- |
| 1 | Resource group exists |
| 2 | Container App has an **HTTPS** FQDN and returns HTTP 200 |
| 3 | Storage account has a **private** blob container with at least one file |
| 4 | You can see Container App **log stream** output |
| 5 | You know how to delete the resource group |

## Create Resource group

1. In the portal search bar, type **Resource groups** and open it.
2. Select **Create**.
3. Set:
   - **Subscription:** the one provided for the workshop
   - **Resource group:** `inh-ccd-lab1-<suffix>`
   - **Region:** West Europe
4. Select **Review + create**, then **Create**.
5. Open the new resource group and confirm it is empty.

## Create the Container Apps

1. In the portal search bar, type **Container Apps** and open it.
2. Select **Create** → **Container App**.
3. **Basics** tab:
   - **Subscription:** same as Part A
   - **Resource group:** `inh-ccd-lab1-<suffix>`
   - **Container app name:** `inh-ccd-app-<suffix>`
   - **Region:** West Europe
   - **Container Apps Environment:** **Create new**
     - Name: `inh-ccd-env-<suffix>`
     - Leave other environment settings at defaults (Consumption / workload profile as offered)
     - **Create**
4. **Container** tab:
   - Use public registry: `mcr.microsoft.com`.
   - Use image: `k8se/quickstart:latest`
5. **Ingress** tab:
   - **Ingress:** Enabled
   - **Ingress traffic:** Accepting traffic from anywhere (external)
   - **Ingress type:** HTTP
   - **Target port:** `80`
6. Select **Review + create**, then **Create**. Wait until deployment finishes (often 1–3 minutes).
7. Open the Container App resource. On **Overview**, copy **Application Url** (HTTPS).
8. Open that URL in a new browser tab. Expect the Container Apps welcome page (HTTP 200).

## Part C — Azure Storage (8 min)

## Create the storage account

1. Open your resource group `inh-ccd-lab1-<suffix>`.
2. Select **Create**.
3. Search for **Storage account** and select **Create**.
4. **Basics** tab:
   - **Storage account name:** `inhccdlab1stg<suffix>` (must be globally unique; if taken, add extra characters)
   - **Region:** West Europe
   - **Performance:** Standard
   - **Redundancy:** Locally-redundant storage (LRS)
5. **Advanced** tab:
   - **Allow Blob anonymous access:** **Disabled** (or uncheck “Allow enabling anonymous access on individual containers”)
6. Select **Review**, then **Create**. Open the resource when it is ready.

### Create a private container and upload a file

1. In the storage account, go to **Data storage** → **Containers**.
2. Select **+ Container**.
   - **Name:** `images`
   - **Anonymous access level:** **Private (no anonymous access)**
3. Select **Create**.
4. Open the `images` container → **Upload**.
5. Upload a small file (for example a text file containing `hello from lab 1`).
6. Confirm the blob appears in the list. Do **not** generate a public URL as the way to share it.

## Cleanup awareness (1 min)

Do **not** delete yet if you continue into Lab 2 with the same resource group.

Otherwise, when you are finished:

1. Open **Resource groups** → `inh-ccd-lab1-<suffix>`.
2. Select **Delete resource group**.
3. Type the resource group name to confirm, then **Delete**.

Deleting the group removes the Container App, environment, and storage account together.

# 01 - Bicep Resource Group Baseline

This project demonstrates deploying a **secure Azure Storage Account** with Bicep at **resource group scope**.

## Features
- HTTPS-only traffic
- TLS 1.2 minimum enforced
- No public blob access

## Deployment
```powershell
az group create --name rg-demo --location eastus
az deployment group create `
  --resource-group rg-demo `
  --template-file main.bicep
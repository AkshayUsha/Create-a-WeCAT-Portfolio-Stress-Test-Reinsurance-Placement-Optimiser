# InsureXThon Azure Deployment Guide

## Prerequisites

1. **Azure Subscription** (Free or Pay-As-You-Go)
2. **Azure CLI** installed (`az --version`)
3. **Git** installed
4. **GitHub Account** with repository access
5. **.NET 8 SDK** (for local testing)
6. **Node.js 18+** (for frontend builds)

## Step 1: Prepare Azure Subscription

### 1.1 Create Resource Group

```bash
# Set variables
SUBSCRIPTION_ID="your-subscription-id"
RESOURCE_GROUP="rg-insurexthon"
LOCATION="eastus"
APP_NAME="insurexthon-app"

# Login to Azure
az login
az account set --subscription $SUBSCRIPTION_ID

# Create resource group
az group create \
  --name $RESOURCE_GROUP \
  --location $LOCATION
```

### 1.2 Create Azure Entra ID App Registration

```bash
# Create app registration
APP_ID=$(az ad app create \
  --display-name "InsureXThon-API" \
  --query appId -o tsv)

echo "App ID: $APP_ID"

# Create client secret (valid 2 years)
CLIENT_SECRET=$(az ad app credential create \
  --id $APP_ID \
  --years 2 \
  --query password -o tsv)

echo "Client Secret: $CLIENT_SECRET"

# Add API permissions (placeholder for your needs)
az ad app permission add \
  --id $APP_ID \
  --api 00000003-0000-0000-c000-000000000000 \
  --api-permissions e1fe6dd8-ba31-4d61-89e6-40ba136cb58b=Scope
```

### 1.3 Create Azure Key Vault

```bash
KEY_VAULT="kv-insurexthon"

az keyvault create \
  --resource-group $RESOURCE_GROUP \
  --name $KEY_VAULT \
  --location $LOCATION

# Store secrets
az keyvault secret set \
  --vault-name $KEY_VAULT \
  --name "AzureOpenAI--ApiKey" \
  --value "your-openai-api-key"

az keyvault secret set \
  --vault-name $KEY_VAULT \
  --name "AzureOpenAI--Endpoint" \
  --value "https://your-resource.openai.azure.com/"

az keyvault secret set \
  --vault-name $KEY_VAULT \
  --name "ConnectionStrings--DefaultConnection" \
  --value "Server=tcp:your-server.database.windows.net,1433;Initial Catalog=InsureXThonDb;Persist Security Info=False;User ID=sqladmin;Password=YourPassword;Encrypt=True;Connection Timeout=30;"
```

## Step 2: Deploy Infrastructure with Bicep

### 2.1 Review Bicep Template

The `infra/main.bicep` file includes:
- Azure SQL Database (Hyperscale)
- App Service Plan (Premium v3)
- App Service (Linux, .NET 8)
- Static Web Apps (for Angular frontend)
- Storage Account (Blob, Queue)
- Application Insights
- Key Vault integration

### 2.2 Deploy Bicep Template

```bash
# Validate template
az deployment group validate \
  --resource-group $RESOURCE_GROUP \
  --template-file infra/main.bicep \
  --parameters infra/parameters.json \
  --parameters appName=$APP_NAME location=$LOCATION

# Deploy infrastructure
az deployment group create \
  --resource-group $RESOURCE_GROUP \
  --template-file infra/main.bicep \
  --parameters infra/parameters.json \
  --parameters appName=$APP_NAME location=$LOCATION

# Wait for deployment (5-10 minutes)
```

### 2.3 Get Deployment Outputs

```bash
az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name main \
  --query properties.outputs
```

Note the outputs:
- `apiUrl` - Your backend API endpoint
- `frontendUrl` - Your frontend URL
- `databaseServer` - SQL Server FQDN
- `appInsightsKey` - For monitoring

## Step 3: Deploy Backend API

### 3.1 Configure GitHub Actions Secrets

Add these secrets to your GitHub repository (`Settings > Secrets and variables`):

```
AZURE_SUBSCRIPTION_ID = your-subscription-id
AZURE_TENANT_ID = your-tenant-id
AZURE_CLIENT_ID = your-app-id
AZURE_CLIENT_SECRET = your-client-secret
AZURE_RESOURCE_GROUP = rg-insurexthon
ACR_LOGIN_SERVER = your-registry.azurecr.io
ACR_USERNAME = your-username
ACR_PASSWORD = your-password
DATABASE_CONNECTION_STRING = Server=tcp:...
AZURE_OPENAI_API_KEY = your-openai-key
AZURE_OPENAI_ENDPOINT = https://your-resource.openai.azure.com/
```

### 3.2 Trigger CI/CD Pipeline

The `.github/workflows/ci-cd.yml` pipeline will automatically:
1. Run tests
2. Build Docker image
3. Push to container registry
4. Deploy to App Service
5. Run database migrations

```bash
# Push to main branch to trigger
git add .
git commit -m "Deploy: Initial infrastructure setup"
git push origin main

# Monitor build
# Go to Actions tab in GitHub → ci-cd.yml workflow
```

### 3.3 Verify API Deployment

```bash
# Get API URL
API_URL=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name main \
  --query 'properties.outputs.apiUrl.value' -o tsv)

# Test API
curl -i "$API_URL/health"
curl -i "$API_URL/swagger/index.html"
```

## Step 4: Deploy Frontend

### 4.1 Build Angular App for Production

```bash
cd frontend/insurexthon-web

# Install dependencies
npm install

# Build for production
ng build --configuration production

# Output in dist/insurexthon-web/
```

### 4.2 Deploy to Static Web Apps

```bash
# Create Static Web App
az staticwebapp create \
  --name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --source-language "typescript" \
  --app-location "frontend/insurexthon-web/dist/insurexthon-web"

# Configure API backend routing
cat > staticwebapp.config.json <<EOF
{
  "routes": [
    {
      "route": "/api/*",
      "rewrite": "/.auth/me"
    },
    {
      "route": "/*",
      "serve": "/index.html",
      "statusCode": 200
    }
  ],
  "navigationFallback": {
    "rewrite": "/index.html",
    "exclude": ["/images/*", "/css/*"]
  }
}
EOF
```

### 4.3 Configure CORS on Backend

Update `src/API/Program.cs`:

```csharp
var frontendUrl = configuration["FrontendUrl"];
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFrontend",
        policy => policy
            .WithOrigins(frontendUrl)
            .AllowAnyMethod()
            .AllowAnyHeader());
});

app.UseCors("AllowFrontend");
```

## Step 5: Database Setup

### 5.1 Run Migrations

```bash
# Connect to Azure SQL
SERVER=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name main \
  --query 'properties.outputs.databaseServer.value' -o tsv)

# Apply migrations via API (or manually)
cd src/API
dotnet user-secrets set ConnectionStrings:DefaultConnection "$DATABASE_CONNECTION_STRING"
dotnet ef database update
```

### 5.2 Verify Database

```bash
# Query using Azure CLI
az sql db query \
  --server $SERVER \
  --database "InsureXThonDb" \
  --username "sqladmin" \
  --password "YourPassword" \
  --query-text "SELECT name FROM sys.tables"
```

## Step 6: Configure Monitoring

### 6.1 Application Insights

Monitor your application:

```bash
# Get instrumentation key
INST_KEY=$(az deployment group show \
  --resource-group $RESOURCE_GROUP \
  --name main \
  --query 'properties.outputs.appInsightsKey.value' -o tsv)

echo $INST_KEY
```

In Azure Portal:
- App Service → Application Insights → View
- Check Live Metrics, Failures, Performance

### 6.2 Set Up Alerts

```bash
az monitor metrics alert create \
  --name "API-HighErrorRate" \
  --resource-group $RESOURCE_GROUP \
  --scopes "/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$APP_NAME" \
  --condition "avg percentage(Total) > 5" \
  --window-size 5m \
  --evaluation-frequency 1m
```

## Step 7: Custom Domain & SSL

### 7.1 Configure Custom Domain

```bash
# For App Service
az webapp config hostname add \
  --webapp-name $APP_NAME \
  --resource-group $RESOURCE_GROUP \
  --hostname "api.insurexthon.com"

# For Static Web App
az staticwebapp custom-domain set \
  --name $APP_NAME \
  --domain-name "app.insurexthon.com"
```

### 7.2 Enable HTTPS

Azure automatically provides SSL certificates for *.azurewebsites.net and custom domains.

## Troubleshooting

### Issue: Deployment Fails

```bash
# Check deployment logs
az deployment operation group list \
  --resource-group $RESOURCE_GROUP \
  --name main \
  --query "[].properties.statusMessage"
```

### Issue: API Not Accessible

```bash
# Check App Service logs
az webapp log tail --resource-group $RESOURCE_GROUP --name $APP_NAME

# Check health endpoint
curl -v "$API_URL/health"
```

### Issue: Database Connection Error

```bash
# Verify SQL Server firewall
az sql server firewall-rule list \
  --server $SERVER \
  --resource-group $RESOURCE_GROUP

# Add your IP if needed
YOUR_IP=$(curl -s https://ipinfo.io/ip)
az sql server firewall-rule create \
  --server $SERVER \
  --resource-group $RESOURCE_GROUP \
  --name "AllowMyIP" \
  --start-ip-address $YOUR_IP \
  --end-ip-address $YOUR_IP
```

## Cost Optimization

- **Use Reserved Instances** for predictable workloads
- **SQL Database:** Serverless pricing for development
- **Scale down** non-production environments
- **Monitor costs** via Azure Cost Management

```bash
# View daily costs
az billing invoice list | head -5
```

## Rollback Deployment

```bash
# Swap slots (if using deployment slots)
az webapp deployment slot swap \
  --resource-group $RESOURCE_GROUP \
  --name $APP_NAME \
  --slot staging

# Or redeploy previous commit
git revert HEAD
git push origin main
```

---

**For support:**
- Check Azure Portal for resource status
- Review Application Insights diagnostics
- Consult [ARCHITECTURE.md](ARCHITECTURE.md) for system design

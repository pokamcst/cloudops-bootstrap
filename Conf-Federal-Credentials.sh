# Login to Azure (do this interactively, not in CI/CD)
az login

# Set variables (replace with your values)
SUBSCRIPTION_ID="8557fe6a-e6ba-4ade-906e-d36316cbf71c"
SERVICE_PRINCIPAL_NAME="github-actions-sp"
GITHUB_ORG="github.com/pokamcst"
GITHUB_REPO="cloudops-bootstrap"

# First, create a new Azure AD app registration specifically for GitHub Actions
APP_NAME="github-actions-oidc-app"

# Create the App Registration and capture the application ID
APP_ID=$(az ad app create --display-name $APP_NAME --query appId -o tsv)
echo "Created App Registration with App ID: $APP_ID"

# Create a service principal for the app
SP_ID=$(az ad sp create --id $APP_ID --query id -o tsv)
echo "Created Service Principal with Object ID: $SP_ID"

# Assign contributor role to the service principal (adjust scope as needed)
az role assignment create \
  --assignee $APP_ID \
  --role "Contributor" \
  --scope "/subscriptions/$SUBSCRIPTION_ID" \
  --description "GitHub Actions automation"

# Now, add federated credentials to the app registration (NOT the service principal)
# For main branch
az ad app federated-credential create \
  --id $APP_ID \
  --parameters "{\"name\":\"github-main\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${GITHUB_ORG}/${GITHUB_REPO}:ref:refs/heads/main\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

# For develop branch
az ad app federated-credential create \
  --id $APP_ID \
  --parameters "{\"name\":\"github-develop\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${GITHUB_ORG}/${GITHUB_REPO}:ref:refs/heads/develop\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

# For feature branches
az ad app federated-credential create \
  --id $APP_ID \
  --parameters "{\"name\":\"github-feature\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${GITHUB_ORG}/${GITHUB_REPO}:ref:refs/heads/feature/*\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

# For pull requests (optional)
az ad app federated-credential create \
  --id $APP_ID \
  --parameters "{\"name\":\"github-pr\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${GITHUB_ORG}/${GITHUB_REPO}:pull_request\",\"audiences\":[\"api://AzureADTokenExchange\"]}"

echo "✅ Setup complete!"
echo "Save these values as GitHub repository secrets:"
echo "AZURE_CLIENT_ID: $APP_ID"
echo "AZURE_TENANT_ID: $(az account show --query tenantId -o tsv)"
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"\",\"issuer\":\"https://token.actions.githubusercontent.com\",\"subject\":\"repo:${GITHUB_ORG}/${GITHUB_REPO}:pull_request\",\"audiences\":[\"api://AzureADTokenExchange\"]}"
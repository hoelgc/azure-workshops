// This is a Bicep module that deploys an Azure Web App along with its required App Service Plan
// Parameters allow us to make our template reusable across different environments
param location string               // The Azure region where the resource will be deployed
param appServicePlanName string     // Name for the App Service Plan (the hosting plan)
param webAppName string             // Name for the Web App that will be created
param skuName string                // The SKU name defines the pricing tier size (e.g., F1, B1, S1)
param skuTier string                // The tier type (e.g., Free, Basic, Standard)
param tags object = {}              // Optional resource tags with a default empty object

// App Service Plan resource - this is the hosting infrastructure for your web app
// Think of it as the virtual machine or container that will run your application
resource appServicePlan 'Microsoft.Web/serverfarms@2022-03-01' = {
    name: appServicePlanName
    location: location
    tags: tags
    kind: 'app'             // Specifies this is for a regular web app (not a function app or container)
    sku: {
        name: skuName       // Defines the compute resources available
        tier:skuTier        // Defines the feature set available
    }
}

// Web App resource - this is your actual web application
// It runs on the App Service Plan defined above
resource webApp 'Microsoft.Web/sites@2022-03-01' = {
    name: webAppName
    location: location
    properties: {
        serverFarmId: appServicePlan.id     // Links the web app to the App Service Plan
        httpsOnly: true                     // Security best practice: forces HTTPS for all traffic
    }
}

// Outputs allow other templates to reference properties of the deployed resources
output webAppName string = webApp.name                              // The name of the created web app
output webAppHostName string = webApp.properties.defaultHostName    // The default URL where the web app will be available

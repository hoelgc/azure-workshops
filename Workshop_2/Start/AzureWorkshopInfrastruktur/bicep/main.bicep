// This is the main Bicep file that orchestrates the deployment of our Azure resources.
// Bicep is a Domain Specific Language (DSL) that represents your Azure infrastructure as code.

// Parameter declarations with decorators for validation
// @allowed decorator restricts the possible values to a predefined set
@allowed([
    'test'
    'prod'
])
param environment string 

// Parameters use decorators to enforce naming conventions and provide metadata
// @minLength and @maxLength ensure the name meets Azure's requirements
// @description provides documentation for the parameter
@minLength(2)
@maxLength(36)
@description('The name of the web site.')
param webSiteName string = 'app-${uniqueString(resourceGroup().id)}'

// Storage accounts have strict naming rules - only lowercase letters and numbers
@minLength(3)
@maxLength(20)
@description('The name of the Azure Storage account. May contain numbers and lowercase letters only!')
param storageAccountName string = 'stazsklimages'

// The SKU of the App Service Plan
@description('The SKU of the App Service Plan')
param appServiceSku string = 'F1'

// The location in which the Azure Storage resources should be deployed.
@description('The location in which the Azure Storage resources should be deployed.')
param location string = resourceGroup().location

// Variables are used to compute values that will be reused throughout the template
// They help maintain consistency and reduce repetition
var servicePlanName = 'asp-${webSiteName}'
var blobContainerName = 'ci-image-${webSiteName}'
var websiteNameWithEnvironment = '${webSiteName}-${environment}'
var storageAccountNameWithEnvironment = '${storageAccountName}${environment}'

// Tags are metadata attached to Azure resources
// They are useful for organizing, managing, and tracking costs
var tags = {
    environment: environment
    project: 'Azure Workshop'
}  

// Conditional expression example: determines the tier based on the SKU
var skuTier = appServiceSku == 'F1' ? 'Free' : 'Basic'

// Modules are reusable components that help organize and maintain your infrastructure
// They promote code reuse and separation of concerns
module webApp 'modules/webapp.bicep' = {
    name: 'webApp' // This is the deployment name, not the resource name
    params: {
        // Pass parameters to the module for configuration
        location: location
        appServicePlanName: servicePlanName
        webAppName: websiteNameWithEnvironment
        skuName: appServiceSku
        skuTier: skuTier
        tags: tags
    }
}

// Another module for storage resources
module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
      location: location
      storageAccountName: storageAccountNameWithEnvironment
      containerName: blobContainerName
      tags: tags
  }
}

// Outputs make specific values available after deployment
// They can be used by other templates or scripts
output webAppName string = webApp.outputs.webAppName
output webAppHostName string = webApp.outputs.webAppHostName
output storageAccountName string = webApp.outputs.storageAccountName
output blobContainerName string = webApp.outputs.blobContainerName

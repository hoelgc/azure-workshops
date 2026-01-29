// This module defines an Azure Storage Account resource

// Input parameters that will be provided by the parent template
param location string           // Azure region where the storage account will be created
param tags object               // Resource tags for organization and billing

// Variables help us define reusable values and improve readability
var storageAccountName = 'st${uniqueString(resourceGroup().id)}'        // Generate a unique storage account name

// Storage Account resource definition
resource storageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = {
    // Name must be globally unique, lowercase, and 3-24 characters long
    name: storageAccountName
    location: location
    tags: tags
    
    // SKU defines the type and replication strategy
    sku: {
        name: 'Standard_LRS'        // Locally-redundant storage (cheapest option)
    }
    
    // Kind specifies the type of storage account
    kind: 'StorageV2'       // General-purpose v2 accounts support all storage services
    
    // Properties define the configuration of the storage account
    properties: {
        minimumTlsVersion: 'TLS1_2'         // Enforce minimum TLS version for security
        supportsHttpsTrafficOnly: true      // Only allow secure connection
        allowBlobPublicAccess: false        // Disable public access for security
        accessTier: 'Hot'                   // Hot tier for frequently accessed data
    }
}

// Outputs allow the parent template to access information about the deployed resource
output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name

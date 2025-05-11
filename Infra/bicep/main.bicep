resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: '8789amitlab'
  location: 'eastus'
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
  properties: {
    accessTier: 'Hot'
  }
}

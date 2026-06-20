targetScope = 'resourceGroup'

param location string = resourceGroup().location
param foundryName string
param tags object = {}

module foundry 'br/public:avm/res/cognitive-services/account:0.15.0' = {
  name: 'deploy-${foundryName}'
  params: {
    name: foundryName
    kind: 'AIServices'                // Foundry account (naya FDP model)
    sku: 'S0'
    location: location
    customSubDomainName: foundryName  // Foundry endpoint + token auth
    allowProjectManagement: true      // projects baad me bana sakte ho
    disableLocalAuth: true            // Entra-only auth
    publicNetworkAccess: 'Enabled'    // lab; prod me Disabled + PE
    tags: tags
    enableTelemetry: false
  }
}

output foundryResourceId string = foundry.outputs.resourceId
output foundryEndpoint string = foundry.outputs.endpoint

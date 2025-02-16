param clusterName string
param dnsPrefix string
param nodeCount int = 1
param vmSize string = 'Standard_DS2_v2'
param resourceGroup string

resource aks 'Microsoft.ContainerService/managedClusters@2023-01-01' = {
  name: clusterName
  location: resourceGroup().location
  resourceGroupName: resourceGroup
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [{
      name: 'agentpool'
      count: nodeCount
      vmSize: vmSize
      mode: 'System'
    }]
    identity: {
      type: 'SystemAssigned'
    }
  }
}

output aksName string = aks.name
output aksFqdn string = aks.properties.fqdn

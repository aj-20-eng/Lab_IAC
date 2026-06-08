// =========================================
// AKS Reusable Module
// Sirf AKS cluster — no monitoring, no alerts
// Usage: module aksModule 'modules/aks/aks.bicep' = { ... }
// =========================================

@description('AKS cluster name')
param clusterName string

@description('Location')
param location string = resourceGroup().location

@description('DNS prefix')
param dnsPrefix string = clusterName

@description('Kubernetes version')
param kubernetesVersion string = '1.29'

@description('VM size — quota ke hisaab se')
@allowed([
  'Standard_D2as_v4'
  'Standard_D4as_v4'
  'Standard_D8as_v4'
  'Standard_B2s'
])
param vmSize string = 'Standard_D2as_v4'

@description('Node count — manual scaling')
@minValue(1)
@maxValue(10)
param nodeCount int = 3

@description('OS disk size GB — 0 = Azure default')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('Tags')
param tags object = {}

// ── AKS Cluster ──
resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-01-01' = {
  name: clusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: nodeCount
        vmSize: vmSize
        osDiskSizeGB: osDiskSizeGB
        osType: 'Linux'
        osSKU: 'Ubuntu'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 110
        enableAutoScaling: false
        enableNodePublicIP: false
        upgradeSettings: {
          maxUnavailable: '0'
        }
      }
    ]
    networkProfile: {
      networkPlugin: 'kubenet'
      loadBalancerSku: 'standard'
    }
    enableRBAC: true
    disableLocalAccounts: false
  }
}

// ── Outputs ──
@description('Cluster name')
output clusterName string = aksCluster.name

@description('Cluster resource ID')
output clusterId string = aksCluster.id

@description('Cluster FQDN')
output fqdn string = aksCluster.properties.fqdn

@description('Kubelet identity object ID — ACR pull ke liye')
output kubeletIdentityObjectId string = aksCluster.properties.identityProfile.kubeletidentity.objectId

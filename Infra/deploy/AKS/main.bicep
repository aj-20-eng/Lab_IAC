@description('Environment')
@allowed(['dev', 'staging', 'prod'])
param environment string = 'dev'

@description('Project name')
param projectName string = 'campusconnect'

@description('Location')
param location string = 'centralindia'

var clusterName = '${projectName}-${environment}-aks'

var nodeConfig = {
  dev: {
    nodeCount: 1
    vmSize: 'Standard_D2as_v4'
  }
  staging: {
    nodeCount: 2
    vmSize: 'Standard_D2as_v4'
  }
  prod: {
    nodeCount: 3
    vmSize: 'Standard_D2as_v4'
  }
}

module aksModule '../../modules/aks/aks.bicep' = {
  name: 'aksDeployment'
  params: {
    clusterName: clusterName
    location: location
    kubernetesVersion: '1.29'
    vmSize: nodeConfig[environment].vmSize
    nodeCount: nodeConfig[environment].nodeCount
    osDiskSizeGB: 0
    tags: {
      environment: environment
      project: projectName
      managedBy: 'bicep'
      owner: 'aj-20-eng'
    }
  }
}

output clusterName string = aksModule.outputs.clusterName
output clusterId string = aksModule.outputs.clusterId
output fqdn string = aksModule.outputs.fqdn
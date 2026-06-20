using './main.bicep'

param location = 'centralindia'
param foundryName = 'aifoundry-lab-cin-01'

param tags = {
  environment: 'lab'
  workload: 'ai-foundry'
}

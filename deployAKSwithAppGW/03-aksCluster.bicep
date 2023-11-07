// https://learn.microsoft.com/azure/aks/troubleshooting#what-naming-restrictions-are-enforced-for-aks-resources-and-parameters
// https://learn.microsoft.com/en-us/azure/templates/microsoft.containerservice/2023-07-01/managedclusters?pivots=deployment-language-bicep
@minLength(3)
@maxLength(63)
@description('Provide a name for the AKS cluster. The only allowed characters are letters, numbers, dashes, and underscore. The first and last character must be a letter or a number.')
param clusterdnsdomain string
param clustername string
param k8sversion string
param subnetid string
param appgwid string

param aksSettings object = {
  clusterdnsname: clusterdnsdomain
  kubernetesVersion: k8sversion
  identity: 'SystemAssigned'
  networkPlugin: 'azure'
  networkPolicy: 'calico'
  serviceCidr: '10.0.0.0/22'
  dnsServiceIP: '10.0.0.10'
  outboundType: 'loadBalancer'
  loadBalancerSku: 'standard'
  sku_tier: 'Paid'
  enableRBAC: false
  aadProfileManaged: false
  adminGroupObjectIDs: []
}

resource aksCluster 'Microsoft.ContainerService/managedClusters@2021-03-01' = {
  name: clustername
  location: resourceGroup().location
  identity: {
    type: aksSettings.identity
  }
  properties: {
    dnsPrefix: clusterdnsdomain
    kubernetesVersion: aksSettings.kubernetesVersion
    enableRBAC: false
    networkProfile: {
      networkPlugin: aksSettings.networkPlugin 
      networkPolicy: aksSettings.networkPolicy 
      serviceCidr: aksSettings.serviceCidr  // Must be cidr not in use any where else across the Network (Azure or Peered/On-Prem).  Can safely be used in multiple clusters - presuming this range is not broadcast/advertised in route tables.
      dnsServiceIP: aksSettings.dnsServiceIP // Ip Address for K8s DNS
      outboundType: aksSettings.outboundType 
      loadBalancerSku: aksSettings.loadBalancerSku 
    }
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: 3
        vmSize: 'Standard_DS2_v2'
        osDiskSizeGB: 30
        osDiskType: 'Ephemeral'
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: subnetid
      }
    ]
    addonProfiles: {
      ingressApplicationGateway: {
        enabled: true
        config: {
          applicationGatewayId: appgwid
        }
      }
    }
  }
}

resource contributorRole 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  scope: subscription()
}

// https://github.com/Azure-Samples/aks-application-gateway-for-containers-bicep/blob/a5154f198e6c7e79368e8fbecfc7f2752d7318e7/bicep/aksCluster.bicep#L869
resource applicationGatewayAgicContributorRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, 'ApplicationGateway', 'contributor')
  scope: resourceGroup()
  properties: {
    roleDefinitionId: contributorRole.id
    principalType: 'ServicePrincipal'
    principalId: aksCluster.properties.addonProfiles.ingressApplicationGateway.identity.objectId
  }
}

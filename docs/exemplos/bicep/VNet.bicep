// Criar Virtual Network com subnets
resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: 'BastionBicep-VNet'
  location: 'eastus2'
  properties: {
    addressSpace: {
      addressPrefixes: ['10.120.0.0/16']
    }
    subnets: [
      {
        name: 'SubApp'
        properties: {
          addressPrefix: '10.120.10.0/24'
        }
      }
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.120.30.0/26'
        }
      }
    ]
  }
}

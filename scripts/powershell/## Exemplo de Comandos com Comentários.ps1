## Exemplo de Comandos com Comentários

```powershell
# Cria um grupo de recursos chamado MyResourceGroup na região East US
New-AzResourceGroup -Name MyResourceGroup -Location eastus

# Cria uma rede virtual (VNet) chamada MyVNet com um prefixo de endereço
$virtualNetwork = New-AzVirtualNetwork -ResourceGroupName MyResourceGroup -Location eastus -Name MyVNet -AddressPrefix 10.0.0.0/16

# Adiciona uma sub-rede chamada AzureBastionSubnet à VNet
$subnetConfig = Add-AzVirtualNetworkSubnetConfig -Name AzureBastionSubnet -AddressPrefix 10.0.1.0/24 -VirtualNetwork $virtualNetwork
$virtualNetwork | Set-AzVirtualNetwork

# Cria um endereço IP público com múltiplas zonas de disponibilidade
$publicIp = New-AzPublicIpAddress -ResourceGroupName MyResourceGroup -Location eastus -Name BastionPublicIP -AllocationMethod Static -Sku Standard -Zone 1,2,3

# Implanta o Azure Bastion na rede virtual
New-AzBastion -ResourceGroupName MyResourceGroup -Name BastionHost -PublicIpAddressId $publicIp.Id -VirtualNetworkId $virtualNetwork.Id -Location eastus -Sku Basic

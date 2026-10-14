---
layout: post
title: 'Deploy Azure Bastion (PowerShell)'
description: 'Aprenda a implantar o Azure Bastion com PowerShell, preparando rede, IP público e acesso seguro às VMs.'
date: 2024-10-21 07:30:00 -0300
categories: [Network]
tags: [Azure, Network, Bastion, PowerShell, VM, Linux, Ubuntu]
slug: 'Deploy-Bastion-PowerShell'
image:
  path: /assets/img/covers/deploy-bastion-powershell.webp
  alt: 'Implantação de VM Linux com PowerShell para uso com Azure Bastion'
---

Fala galera!👋

**Bem-vindo ao Blog Cloud Insights!** ☁️

Neste post, vamos explorar como realizar o Deploy do Azure Bastion via PowerShell.

### Pré-requisitos

Antes de começarmos nosso laboratório, verifique se você possui:

- Uma conta do Azure com uma assinatura/subscription ativa.

> Caso você não tenha uma subscription, você pode criar uma Trial. Mais informações consulte <a href="https://azure.microsoft.com/en-us/" target="_blank">aqui</a>.
{: .prompt-tip }

#### Passo 1: Instale o PowerShell 7

Primeiro, caso você não tenha PowerShell 7 instalado, aqui estão os links com a documentação oficial para diferentes sistemas operacionais:

- <a href="https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4" target="_blank">Windows</a>
- <a href="https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-macos?view=powershell-7.4" target="_blank">macOS</a>
- <a href="https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-linux?view=powershell-7.4" target="_blank">Linux</a>

No meu laboratório vou simular a instalação do Powershell no Windows 10.

- Verifique as versões disponiveis do PowerShell 7 com o comando a seguir:

```powershell
winget search Microsoft.PowerShell
```

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/Verifique%20a%20versao%20do%20Powershell7.png){: .shadow .rounded-10}

- Instale o Powershell

```powershell
winget install --id Microsoft.PowerShell --source winget
```

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/02-Instando%20Powershell7%20na%20versao%20mais%20recente.png){: .shadow .rounded-10}

- Instale também o Azure PowerShell

> Para instalar o Azure PowerShell siga o passo-a-passo disponivel <a href="https://learn.microsoft.com/en-us/powershell/azure/install-azps-windows?view=azps-12.4.0&tabs=powershell&pivots=windows-msi" target="_blank">aqui</a>.
{: .prompt-tip }

#### Passo 2: Verifique a Instalação

- Após a instalação, verifique se o Powershell 7 está funcionando corretamente. Abra o powershell em sua máquina e execute o comando abaixo para validar a versão:

```powershell
$PSVersionTable.PSVersion
```

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/07VersaoPowershell.png){: .shadow .rounded-10}

> Obs.: Talvez seja necessário reiniciar sua máquina.
{:.prompt-info}

#### Passo 3: Faça login com Azure PowerShell

> Dica: Se você tiver acesso em mais de uma subscription, você pode executar o comando a seguir para determinar qual subscription você pretende deixar como default para toda vez que fizer login no Azure. Clique <a href="https://learn.microsoft.com/en-us/powershell/module/az.accounts/?view=azps-12.4.0&form=MG0AV3" target="_blank">aqui</a> para validar mais parâmetros que você pode utilizar.
{:.prompt-info}

```powershell
Update-AzConfig -DefaultSubscriptionForLogin subscriptionID
```
![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/05-SetandoSubscriptionDefault.png){: .shadow .rounded-10}

- Com o Powershell aberto execute o comando a seguir para logar no Azure.

```powershell
Connect-AzAccount -DeviceCode
```

- Abra o link e copie o código para logar com suas credenciais.

> *Depois de ter logado você vai notar que no terminal vai aparecer a subscription default que você associou.*
{:.prompt-info}

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/06-Connect-AzAccount%20DeviceCode.png){: .shadow .rounded-10}

> Para mais informações sobre os métodos de login com o Azure Powershell, consulte <a href="https://learn.microsoft.com/en-us/powershell/azure/authenticate-azureps?view=azps-12.4.0&form=MG0AV3" target="_blank">aqui</a>.
{: .prompt-tip }

---

#### Passo 4: Deploy dos Recursos Base

- Crie um novo resource-group com o comando a seguir:

```powershell
New-AzResourceGroup -Name RG-BastionPS -Location eastus2
```

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/08-ResourceGroup.png){: .shadow .rounded-10}

- Crie uma nova Virtual Network + AzureBastionSubnet:

> Obs.: Vamos aproveitar e criar a subnet (subApp). Ela será necessária quando formos criar a VM Linux para testarmos o acesso via Azure Bastion.
{:.prompt-info}

```powershell
$subApp = New-AzVirtualNetworkSubnetConfig -Name subApp -AddressPrefix "10.110.10.0/24" # Cria uma variável da subApp

$virtualNetwork = New-AzVirtualNetwork -ResourceGroupName RG-BastionPS -Location eastus2 -Name BastionPSVNet -AddressPrefix 10.110.0.0/16 -Subnet $subApp # Faz o deploy da BastionPSVNet e cria uma variável dela associando a subnet subApp

Add-AzVirtualNetworkSubnetConfig -Name AzureBastionSubnet -VirtualNetwork $virtualNetwork -AddressPrefix "10.110.30.0/26" # Cria a AzureBastionSubnet

$virtualNetwork | Set-AzVirtualNetwork # Associa a AzureBastionSubnet na VNet BastionPSVNet
```
![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/10-DeployVNET+Subnets.png){: .shadow .rounded-10}

- Aqui é uma visão da VNet + Subnets que acabamos de criar:

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/101VNet%20criada.png){: .shadow .rounded-10}

---

#### Passo 5: Deploy do Azure Bastion

Para que seja possível fazer o deploy do Azure Bastion, necessitamos ter um Public-IP. Veja abaixo como fazer a criação dele.

```powershell
$publicIp = New-AzPublicIpAddress -ResourceGroupName RG-BastionPS -Location eastus2 -Name BastionPS-PIP -AllocationMethod Static -Sku Standard -Zone 1,2,3
```

![azure-automation-account](/assets/img/Lab01-Bastion/Bastion-PS/11DeployPublicIP.png){: .shadow .rounded-20 }

> Se quiser saber mais sobre o Public IP, para entender sua Limitações, Preços e SKU, consulte <a href="https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses" target="_blank">aqui</a>.
{: .prompt-tip }

- Agora vamos fazer o Deploy do Azure Bastion. Vamos utilizar os recursos base que criamos acima.

```powershell
New-AzBastion -ResourceGroupName RG-BastionPS -Name BastionHostPS -PublicIpAddressId $publicIp.Id -VirtualNetworkId $virtualNetwork.Id -Sku Basic
```

![azure-automation-account](/assets/img/Lab01-Bastion/Bastion-PS/12-DeplyAZBastion.png){: .shadow .rounded-20 }

- Com o Deploy do Bastion concluído, podemos agora fazer o login em uma VM Linux para validar a funcionalidade do recurso.

![azure-automation-account](/assets/img/Lab01-Bastion/Bastion-PS/13-RecursosCriados.png){: .shadow .rounded-20 }

#### Passo 6: Deploy VM Linux para teste de acesso

- Vamos fazer o deploy de uma VM Linux para validar o acesso com o Azure Bastion.

- Crie uma NSG (Network Security Group) + Nic (Interface de Rede) + Rule (Regra de Acesso SSH = Porta 22)

> No exemplo a seguir, estou criando uma regra com a porta 22 aberta para acesso externo (Internet). Fiz isso apenas para cenários de teste do Azure Bastion. Nunca faça isso em um ambiente de Produção. Como melhor prática, realize o micro-gerenciamento das regras NSG na sua organização, permitindo apenas a comunicação estritamente necessária.
{: .prompt-danger }

```powershell
# Crie um Network Security Group (NSG) e uma Rule para permitir SSH
$nsg = New-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Location $location -Name "nsg-ps"
$nsgRuleSSH = Add-AzNetworkSecurityRuleConfig -Name "Allow-SSH" -NetworkSecurityGroup $nsg -Protocol "Tcp" -Direction "Inbound" -Priority 150 -SourceAddressPrefix "*" -SourcePortRange "*" -DestinationAddressPrefix "*" -DestinationPortRange 22 -Access "Allow"
$nsg | Set-AzNetworkSecurityGroup
```

```powershell
# Defina variáveis
$resourceGroupName = "RG-BastionPS"
$location = "eastus2"
$vmName = "vm-lnx"
$adminUsername = "usernamedavm"
$adminPassword = "senhadeacessonavm"  # adicione uma senha complexa
$vnetName = "BastionPSVNet"
$subnetName = "subApp"
$nsgName = "nsg-ps"
$nicName = "vm-lnx-nic"
```
```powershell
# Obtenha os recursos existentes
$virtualNetwork = Get-AzVirtualNetwork -ResourceGroupName $resourceGroupName -Name $vnetName
$subnet = Get-AzVirtualNetworkSubnetConfig -VirtualNetwork $virtualNetwork -Name $subnetName
$nsg = Get-AzNetworkSecurityGroup -ResourceGroupName $resourceGroupName -Name $nsgName
```
```powershell
# Crie uma interface de rede (NIC)
$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroupName -Location $location -Name $nicName -SubnetId $subnet.Id -NetworkSecurityGroupId $nsg.Id
```
```powershell
# Crie a VM com usuário e senha
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize "Standard_DS1_v2" | `
  Set-AzVMOperatingSystem -Linux -ComputerName $vmName -Credential (Get-Credential -UserName $adminUsername -Message "Enter password") | `
  Set-AzVMSourceImage -PublisherName "Canonical" -Offer "UbuntuServer" -Skus "18.04-LTS" -Version "latest" | `
  Add-AzVMNetworkInterface -Id $nic.Id
```
```powershell
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig
```

![azure-automation-account](/assets/img/Lab01-Bastion/Bastion-PS/15-DeployVMLX.png){: .shadow .rounded-20 }

> Obs.: Em breve vou montar laboratórios ensinando como fazer o deploy de VMs em diferentes formatos, além do Powershell.
{:.prompt-info}


### Passo 7: Acessando VMs Linux

- Acesse o Portal do Azure e Localize sua VM Linux.
  - Já logado no [Portal do Azure](https://portal.azure.com/).
  - Navegue até o **Resource-Group** onde está a VM Linux que criamos.

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/16-LocalizandoVM.png){: .shadow .rounded-10}

### Passo 8: Conecte-se via Bastion

- Clique na sua máquina virtual Linux para abrir a página de detalhes.
  - No painel de navegação da VM, clique em **Connect**.
  - Selecione **Connect via Bastion**.
  - Uma nova tela será exibida. Insira as credenciais de login da sua VM (nome de usuário e senha).
  - Clique em **Connect**.

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/14-LogandoVM.png){: .shadow .rounded-10}


![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/14-LogandoVM2.png){: .shadow .rounded-10}

  - Após alguns segundos, uma nova janela será aberta, permitindo que você interaja com a linha de comando da sua VM Linux.

![resource-group](/assets/img/Lab01-Bastion/Bastion-PS/14-LogandoVM3.png){: .shadow .rounded-10}

## Documentação Adicional

Para mais detalhes, você pode consultar a documentação oficial no Microsoft Learn:

<a href="https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-powershell?view=azureml-api-2" target="_blank">Deploy VMs Linux usando o Powershell</a>

<a href="https://learn.microsoft.com/en-us/azure/bastion/bastion-create-host-powershell?form=MG0AV3" target="_blank">Deploy Azure Bastion usando o PowerShell</a>

## Conclusão

Agora você sabe como realizar o deploy do Azure Bastion e de uma Virtual Machine Linux através do PowerShell.

Até a próxima!! 😉

![resource-group](/assets/img/02/cloudinsights3.png){: .shadow .rounded-10}

#CloudInsights #Azure #Tech #Cloud #Security #Network #PowerShell

---

[![Build and Deploy](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml/badge.svg)](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml)


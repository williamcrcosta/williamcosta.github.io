---
layout: post
title: 'Deploy Azure Bastion (Terraform)'
date: 2025-01-17 08:30:00 -0300
categories: [Network]
tags: [Azure, Network, Bastion, Terraform]
slug: 'Deploy-Bastion-Terraform'
#image:
#  path: assets/img/01/image.gif
---

Fala galera!👋

**Bem-vindo ao Blog Cloud Insights!** ☁️

Neste post, vamos explorar como realizar o Deploy do Azure Bastion via Terraform.

### Pré-requisitos

Antes de começarmos nosso laboratório, verifique se você possui:

- Uma conta do Azure com uma assinatura/subscription ativa.

> Caso você não tenha uma subscription, você pode criar uma Trial. Mais informações consulte <a href="https://azure.microsoft.com/en-us/" target="_blank">aqui</a>.
{: .prompt-tip }

- Um Service Principal.

> Caso voce não tenha

#### Passo 1: Instale o PowerShell 7

## 1. Primeiro passo aqui é realizar o download da última versão do executavel do Terraform para Windows.

- Acesse a pagina da Hashicorp para fazer o download do pacote, depois disso extraia o conteudo na pasta Downloads, logo em seguida crie um novo diretório no disco C com nome "Terraform" e adicione o conteudo extraido lá

-- Adicionar aqui um gif ilustrando

## 2. Criar uma nova pasta para começar a trabalhar no nosso projeto.

Crie uma nova pasta, e inicie o VSCode a partir dela para iniciar a codificação dos recursos que necessitamos criar.

## 3. Criar estrutura de arquivos

- Vamos criar uma estrutura de arquivos para começar a trabalhar na codificação dos recursos que necessitamos criar.

Adicioanr um print dos arquivos que criamos

## 4. Vamos iniciar codificando dos nossos arquivos .tf

- Aqui vamos adicionar as informações de Provider do AzureRM. Adicione o conteudo abaixo no arquivo provider.tf

```hcl
provider "azurerm" {
  # Configure the Azure Resource Manager provider
  features {} # Configuration options for the provider
}
```

- Aqui vamos adicionar as informaçoes da versao mais recente do Required_Providers. Adicione o conteudo abaixo no arquivo version.tf
  Se quiser consultar uma versao mais recente, pode buscar no link a seguir. Required_Providers

```hcl
# Configure Terraform to use the required provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.16.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "3.1.0"
    }
  }
}
```

- Aqui vamos adicionar o codigo para criar um Resource-Group. Adicione o conteudo abaixo no arquivo rg.tf

```hcl
# Crie um recurso do tipo azurerm_resource_group
# mais informacoes: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "rg" {
  name     = "rg"
  location = "East US 2"
}
```

- Aqui vamos adicionar o codigo para criar uma virtual-network e uma subnet. Adicione o conteudo abaixo no arquivo vnet.tf

```hcl
# Crie um recurso virtual_network
# mais informacoes: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.101.0.0/16"] # Espaco de enderecamento da VNet
}

# Crie um recurso subnet
# mais informacoes: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "subnet" {
  name                              = "subnet"
  resource_group_name               = azurerm_resource_group.rg.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = ["10.101.10.0/24"] # Sub-rede criada na VNet
  private_endpoint_network_policies = NetworkSecurityGroupEnabled
}
```

- Aqui vamos adicionar o codigo para criar algumas tags, melhor pratica para identificar nossos recursos dentro do Azure. Adicione o conteudo abaixo no arquivo locals.tf

```hcl
locals {
  tags = {
    Environment = "Dev"
    Project     = "Bastion"
    Managedby   = "Terraform"
  }
}
```

- E por fim, agora vamos adicionar o codigo para criar o Azure Bastion. Adicione o conteudo abaixo no arquivo bastion.tf

```hcl
# Cria um recurso do tipo public_ip para ser usado pelo Bastion
# mais informacoes: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "bastion-pip" {
    name                = "bastion-pip"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    allocation_method   = "Static"
    tags                = local.tags
}

# Cria um recurso do tipo azure_bastion_host
# mais informacoes: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host
resource "azurerm_bastion_host" "bastion" {
    name                = "bastion"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name
    sku                 = "Standard"

    ip_configuration {
        name                 = "configuration"
        subnet_id            = azurerm_subnet.subnet.id
        public_ip_address_id = azurerm_public_ip.bastion-pip.id
    }
}
```

## 4. Inicializar o Terraform

 Ja com todos os arquivos codificados, vamos iniciar o Terraform. No terminal do VSCode, digite o comando abaixo.

```powershell
terraform init
```

adicionar um print.

O comando terraform init é o primeiro passo para configurar um projeto no Terraform. Ele faz uma série de coisas essenciais:

- Prepara o Diretório de Trabalho: Inicializa um novo diretório de trabalho ou reconfigura um existente. Esse diretório contém os arquivos de configuração do Terraform.

- Instala Plugins de Provedor: Baixa e instala os plugins de provedor que são especificados nos arquivos de configuração. Os provedores são responsáveis por interagir com os serviços da nuvem ou outras APIs.

- Inicializa o Backend: Configura o backend que o Terraform utilizará para armazenar o estado da infraestrutura. O estado é um arquivo que mantém o mapeamento das configurações do Terraform com os recursos reais.

É basicamente o comando que prepara tudo para que você possa criar, alterar e destruir infraestrutura com o Terraform. 😊


- Em seguida execute o terraform validate para verificar se os arquivos de configuração do Terraform estão corretos em termos de sintaxe e lógica. Ele não faz alterações nos recursos, apenas valida a configuração. É útil para identificar erros antes de aplicar o plano (terraform plan).

```powershell
terraform validate
```

- Agora execute o "terraform fmt". Este comando formata os arquivos de configuração para seguir um estilo de código consistente e legível. Corrige indentação, alinhamento e outros aspectos de formatação conforme as convenções do Terraform. É uma boa prática usar esse comando regularmente para manter a base de código organizada.

```powershell
terraform fmt
```

- Seguido todos esses passos, agora vamos criar um plano, execute o comando "terraform plan -out meu_plano.out".

```powershell
terraform plan -out meu_plano.out
```

adicionar print do que sera criado.

- Agora, com o plano já criado, já sabemos quais recursos serão criados. Vamos executar o "terraform apply meu_plano.out".

```powershell
terraform apply meu_plano.out
```

adicionar print do que sera criado.


## 5. Planejar a criação dos recursos

## Conclusão

Agora você sabe como realizar o deploy do Azure Bastion e de uma Virtual Machine Linux através do PowerShell.

Até a próxima!! 😉

![resource-group](/assets/img/02/cloudinsights3.png){: .shadow .rounded-10}

#CloudInsights #Azure #Tech #Cloud #Security #Network #PowerShell

---

[![Build and Deploy](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml/badge.svg)](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml)


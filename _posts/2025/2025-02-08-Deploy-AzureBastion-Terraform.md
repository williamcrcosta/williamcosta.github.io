---
layout: post
title: 'Deploy Azure Bastion (Terraform)'
date: 2025-02-08 08:30:00 -0300
categories: [Network]
tags: [Azure, Network, Bastion, Terraform]
slug: 'Deploy-Bastion-Terraform'
#image:
#  path: assets/img/01/image.gif
---

Fala galera!👋

**Bem-vindo ao Blog Cloud Insights!** ☁️

Neste post, vamos explorar como realizar o Deploy do Azure Bastion via Terraform.

### Pré-Requisitos

Antes de começarmos nosso laboratório, verifique se você possui:

- Uma conta do Azure com uma assinatura ativa.

> Caso você não tenha uma subscription, você pode criar uma Trial. Mais informações consulte <a href="https://azure.microsoft.com/en-us/" target="_blank">aqui</a>.
{: .prompt-tip }

- Um Service Principal (um tipo de identidade no Azure usada para autenticação) com permissionamento adequado.

> Obs.: Aqui estou utilizando um Service Principal com permissão de "Global Administrator" no Entra ID e com a permissao de Contributor na minha assinatura. Para saber como adicionar permissões elevadas em uma conta, consulte <a href="https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/manage-roles-portal?tabs=admin-center" target="_blank">aqui</a>.
{:.prompt-info}

- Ter o VSCode Instalado em seu Sistema Operacional Windows com as extensões Azure Terraform, Hashicorp Terraform e PowerShell.

> Caso não tenha o VSCode Instalado, faça o Download do instalador <a href="https://code.visualstudio.com/sha/download?build=stable&os=win32-x64" target="_blank">aqui</a>.
{:.prompt-info}

- Ter o Terraform instalado no seu computador.

> Caso não tenha o Terraform instalado, siga este <a href="https://cloudinsights.com.br/posts/Service-Principal-Terraform/#1-primeiro-passo-aqui-%C3%A9-realizar-o-download-da-%C3%BAltima-vers%C3%A3o-do-execut%C3%A1vel-do-terraform-para-windows" target="_blank">procedimento</a>.
{:.prompt-info}

### 1. Criar estrutura de Arquivos

- Crie uma nova pasta e abra o VSCode "Visual Studio Code" nela para começar a configurar os recursos necessários.
  - Vamos estruturar os arquivos do projeto para iniciar a criação dos recursos com Terraform. Crie a estrutura de arquivos a abaixo:

![Folder-Structure](/assets/img/Lab04-VMLNX/FolderStructure.png){: .shadow .rounded-10}

### 2. Vamos iniciar codificando nossos arquivos

- Aqui vamos adicionar as informações do nosso ambiente no Azure.
  - *Precisaremos setar algumas variáveis de ambiente.*
- Adicione esse conteúdo no arquivo ***powershell-credencials-azure.ps1***.

```powershell
$env:ARM_CLIENT_ID = "Client ID do seu SPN" # Aqui estou adicionando as informações do meu Service Principal que contém a permissão de Global Administrator no Entra ID
$env:ARM_TENANT_ID = "O ID do seu Tenant no EntraID"
$env:ARM_SUBSCRIPTION_ID = "ID da sua subscription"
$env:ARM_CLIENT_SECRET = "Secret do seu SPN" # Aqui estou adicionando as informações do meu Service Principal que contém a permissão de Global Administrator no Entra ID
```

- Aqui vamos adicionar as informações de Provider do AzureRM. Adicione o conteúdo abaixo no arquivo ***provider.tf***.

```hcl
provider "azurerm" {
  # Configure the Azure Resource Manager provider
  features {} # Configuration options for the provider
}
```

- Aqui vamos adicionar as informações da versão mais recente do Provider AzureRM e HTTP. Adicione o conteúdo abaixo no arquivo ***version.tf***.

```hcl
# Configure Terraform para usar os provedores necessários
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.17.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
  }
}
```

> *Se quiser consultar uma versão mais recente, pode buscar nos links a seguir <a href="https://registry.terraform.io/providers/hashicorp/azurerm/latest" target="_blank">**AzureRM Provider**</a> e <a href="https://registry.terraform.io/providers/hashicorp/http/latest" target="_blank">**HTTP-Provider**</a>*.
  {: .prompt-tip }

- Agora vamos iniciar a codificação dos recursos que precisamos fazer o deploy. Vamos iniciar com as tags. Ela é importante para identificar os recursos no Portal da Azure. Adicione o conteúdo abaixo no arquivo ***locals.tf***.

```hcl
# Tags padrões para os recursos criados pelo Terraform
locals {
  tags = {
    # Ambiente em que o recurso esta sendo criado
    Environment = "Dev"
    # Nome do projeto que o recurso esta sendo criado
    Project = "VM-Ubuntu2404"
    # Ferramenta que esta gerenciando o recurso
    Managedby = "Terraform"
  }
}
```

- Agora vamos adicionar o código para criar um Resource-Group. Adicione o código abaixo no arquivo ***rg.tf***.

```hcl
# Crie um recurso do tipo resource_group
# mais informacoes: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "rg-vm-lnx" {
  name     = "rg-vm-lnx"
  location = "East US 2"
  tags     = local.tags
}
```

- Agora vamos adicionar o código para criar uma Virtual Network. Adicione o conteúdo abaixo no arquivo ***vnet.tf***.

```hcl
# Crie um recurso do tipo azurerm_virtual_network
# mais informacoes: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.rg-vm-lnx.name
  location            = azurerm_resource_group.rg-vm-lnx.location
  address_space       = ["10.101.0.0/16"] # Espaco de enderecamento da VNet
  tags                = local.tags
}

# Crie um recurso do tipo azurerm_subnet
# mais informacoes: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "subnet" {
  name                              = "subnet"
  resource_group_name               = azurerm_resource_group.rg-vm-lnx.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = ["10.101.10.0/24"] # Sub-rede criada na VNet
  # Habilita a aplicacao de politicas de seguranca na sub-rede a nivel de NSG
  private_endpoint_network_policies = "NetworkSecurityGroupEnabled"
}
```

- Agora vamos adicionar o código para criar uma NSG (Network Security Group) e uma rule. Adicione o conteúdo abaixo no arquivo ***nsg.tf***.

```hcl
# Esse código faz uma solicitação HTTP para obter o endereço IP público da máquina que está executando o Terraform. É como perguntar "Qual é o meu IP?" e obter a resposta diretamente na sua configuração do Terraform.
data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

# Cria um recurso do tipo network_security_group
# mais informacoes: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  resource_group_name = azurerm_resource_group.rg-vm-lnx.name
  location            = azurerm_resource_group.rg-vm-lnx.location
  tags                = local.tags

  # Permite que as requisições sejam recebidas somente a partir do meu IP público, garantindo que apenas eu consiga acessar a VM.
  security_rule {
    name                       = "SSHInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = chomp(data.http.myip.response_body)
    destination_address_prefix = azurerm_windows_virtual_machine.vm-lnx.private_ip_address # Aqui no destino você garante que a origem vai conseguir comunicação na porta 3389 somente no IP Privado da VM que vamos criar.
  }
}

# Associa o NSG à Subnet
# mais informacoes: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
resource "azurerm_subnet_network_security_group_association" "association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

```

- Aqui vamos adicionar o código das nossas variáveis que iremos utilizar. Adicione o conteúdo abaixo no arquivo ***variables.tf***.

> Em vez de adicionar os valores das variáveis no arquivo `variables.tf`, vamos adicioná-las como variáveis de ambiente ao executar o Terraform. Isso ajuda a manter dados sensíveis, como senhas, fora dos arquivos de configuração do Terraform.
{: .prompt-warning }

```hcl
# Variável para chave pública SSH
variable "key_pub_lnx" {
  description = "Chave pública para acesso remoto via SSH."
  type        = string
  sensitive   = true
}
```

- Por fim, vamos adicionar alguns outputs para facilitar a visualização dos resultados do deploy. Adicione o conteúdo abaixo no arquivo ***output.tf***.

```hcl
# Saída do endereço IP público da máquina virtual
output "public_ip" {
  value = azurerm_public_ip.pip-vm-lnx.ip_address
}

# Saída do endereço IP privado da interface de rede da máquina virtual
output "private_ip" {
  value = azurerm_network_interface.nic-vm-lnx.private_ip_address
}

# Saída do nome da máquina virtual
output "vm_name" {
  value = azurerm_linux_virtual_machine.vm-lnx.name
}
```

![Terraform-Output](/assets/img/Lab03-VMWindowsServer/TerraformOutput.png){: .shadow .rounded-10}

### 4. Inicializar o Terraform

 Já com todos os arquivos codificados, vamos iniciar o Terraform. No terminal do VSCode, digite o comando abaixo. O comando `terraform init` inicializa um novo ou existente diretório do Terraform configurando o ambiente, baixando os plugins e preparando o estado para implantação.

```powershell
terraform init
```

![Terraform-Init](/assets/img/Lab04-VMLNX/TerraformInit.png){: .shadow .rounded-10}

### 5. Validar se a configuração está Correta

- Nesta etapa vamos executar o `terraform validate` para verificar se os arquivos de configuração criados estão corretos em termos de sintaxe e lógica. Ele não faz alterações nos recursos, apenas valida a configuração. É útil para identificar erros antes de executar o plano *terraform plan*. 😉

```powershell
terraform validate
```

![Terraform-Validate](/assets/img/Lab04-VMLNX/TerraformValidate.png){: .shadow .rounded-10}

#### 6. Validar a formatação dos Arquivos

- Agora vamos executar o `terraform fmt`. Este comando formata os arquivos de configuração para seguir um estilo de código consistente e legível. Corrige indentação, alinhamento e outros aspectos de formatação conforme as convenções do Terraform. É uma boa prática usar esse comando regularmente para manter a base de código organizada.

```powershell
terraform fmt
```

![Terraform-FMT](/assets/img/Lab04-VMLNX/TerraformFMT.png){: .shadow .rounded-10}

#### 7. Criar as variáveis de ambiente para ser possivel se conectar na Azure

- Neste passo com o powershell aberto, dentro do VSCode, execute o comando abaixo. Ele vai executar o arquivo ***powershell-credencials-azure.ps1***.

```powershell
.\powershell-credencials-azure.ps1
```

<center> Notem na figura que eu validei se as variáveis foram adicionadas corretamente </center>
![Set-Azure-Variables](/assets/img/Lab04-VMLNX/EnvironmentVariables.png){: .shadow .rounded-10}

- Aqui vamos adicionar a variavel de ambiente da chave Publico que criamos mais acima. Adicione o comando abaixo em seu terminal do PowerShell.

```powershell
$env:TF_VAR_key_pub_lnx="Adicione aqui o conteudo da sua chave publica"
```

![Set-VM-Variables](/assets/img/Lab04-VMLNX/Key_TF_Variable.png){: .shadow .rounded-10}

#### 8. Criar plano de Execução

- Seguido todos esses passos, agora vamos criar um plano, execute o comando `terraform plan -out my_vm-lnx.out`. Ele cria um plano de execução e armazena em um arquivo. O arquivo my_vm-lnx.out é criado para revisar o que será feito sem aplicar as mudanças.

```powershell
terraform plan -out my_vm-lnx.out
```

![Terraform-Plan](/assets/img/Lab04-VMLNX/TerraformPlan.png){: .shadow .rounded-10}

> Na figura acima, estou apresentando somente a quantidade de recursos que serão criados. Isso é feito para proteger a segurança dos dados e evitar exposição desnecessária de informações sensíveis, como o ID da subscription onde os recursos serão criados. Note que ele já me traz as informações de outputs que criamos logo acima.
{: .prompt-danger }

#### 8. Fazer o deploy dos Recursos

- Agora, com o plano já executado, já sabemos quais recursos serão criados. Vamos executar o `terraform apply my_vm-lnx.out`.
  - Esse comando aplica as mudanças especificadas no arquivo de plano gerado pelo comando `terraform plan`.

```powershell
terraform apply my_vm-lnx.out
```

![Terraform-Apply](/assets/img/Lab04-VMLNX/TerraformApply.png){: .shadow .rounded-10}

#### 09. Listar recursos criados pelo Terraform

- Vamos executar o comando `terraform state list`. Ele é utilizado para listar todos os recursos gerenciados pelo estado do Terraform.
  - Este comando exibe uma lista de recursos que foram criados, atualizados ou destruídos pelo Terraform e que estão sendo rastreados no arquivo tfstate.

```powershell
terraform state list
```

![Terraform-State-List](/assets/img/Lab04-VMLNX/TerraformState.png){: .shadow .rounded-10}

#### 11. Validar recursos criados no Portal Azure

- A estrutura de recursos criada pode ser vista na figura abaixo.

![RG-Recursos](/assets/img/Lab04-VMLNX/RG.png){: .shadow .rounded-10}

- Os detalhes da VM criada podem ser vistos na figura abaixo.

![VM-Portal](/assets/img/Lab04-VMLNX/CreateVM.png){: .shadow .rounded-10}

- A regra de segurança de rede (NSG) foi criada com origem somente meu IP público e destino o IP da VM, como visto na figura abaixo.

![NSG-Rule](/assets/img/Lab04-VMLNX/NSGRule.png){: .shadow .rounded-10}


#### 12. Acessar VM criada

- Nesta parte, com o usuário e chave SSH configurados como variáveis de ambiente, podemos conectar à VM utilizando o protocolo SSH com autenticação por chave pública.

Execute o comando abaixo e, na sequência, aceite a conexão

```powershell
# Adicione o IP Publico da VM que foi criada. O IP da VM você obtém como output do terraform apply
ssh -i key-pub-lnx terraform@x.x.x.231
```

![VM-Access](/assets/img/Lab04-VMLNX/VMAccess+Version.png){: .shadow .rounded-10}

#### 12. Remover recursos criados com Terraform Destroy

- Agora que nós criamos a VM, testamos, vamos fazer a remoção dela. O comando `terraform destroy` é utilizado para destruir todos os recursos gerenciados pelo Terraform em sua configuração. Isso significa que ele apagará todos os recursos da infraestrutura que foram criados ou gerenciados pelo Terraform.

> Esse comando é útil quando você deseja desfazer todas as mudanças aplicadas ou quando precisa limpar o ambiente.
{: .prompt-tip }

![Terraform-Destroy](/assets/img/Lab04-VMLNX/TerraformDestroy.png){: .shadow .rounded-10}
![Terraform-Destroy2](/assets/img/Lab04-VMLNX/TerraformDestroy2.png){: .shadow .rounded-10}

> É importante lembrar que o comando terraform destroy apaga todos os recursos gerenciados pelo Terraform, então use-o com cautela, especialmente em ambientes de produção. Sempre revise o plano de destruição antes de confirmar para garantir que você não está apagando algo por engano.
{: .prompt-danger }

### Resumo:

Neste artigo, exploramos o processo de automação da implantação de uma máquina virtual Ubuntu Server no Azure utilizando o Terraform. Discutimos os pré-requisitos necessários, incluindo a configuração de um Service Principal e a instalação das ferramentas essenciais. Além disso, detalhamos a estruturação dos arquivos do projeto e a geração de chaves SSH para acesso seguro à VM. Por fim, apresentamos o código necessário para a criação dos recursos no Azure, destacando a eficiência e consistência que a automação com Terraform proporciona.

### Conclusão:

A automação da infraestrutura em nuvem com o Terraform não apenas simplifica o processo de implantação, mas também garante consistência e rastreabilidade nas configurações. Ao seguir os passos delineados neste guia, você está apto a criar e gerenciar máquinas virtuais no Azure de maneira eficiente e reproduzível. Essa abordagem reduz a probabilidade de erros manuais e facilita a manutenção e escalabilidade dos recursos na nuvem.

### Próximos Passos:

Agora que sua VM já está rodando, que tal explorar mais possibilidades? Aqui estão algumas sugestões para continuar aprendendo:

- Adicionar um disco extra à VM para armazenar mais dados 💾.
- Automatizar a instalação de pacotes na VM com cloud-init 🛠️.
- Utilizar o Terraform Remote State para armazenar o estado da infraestrutura na nuvem 🌍.

*Essas são apenas algumas ideias para aprimorar sua infraestrutura com Terraform! Continue explorando novas configurações e torne seu ambiente ainda mais seguro e automatizado.*

Até a próxima!! 😉

![resource-group](/assets/img/02/cloudinsights3.png){: .shadow .rounded-10}

#CloudInsights #Azure #Tech #Cloud #Security #Network #Terraform #InfraAsCode

---

[![Build and Deploy](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml/badge.svg)](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml)


















































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


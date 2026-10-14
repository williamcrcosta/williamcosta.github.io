---
layout: post
title: 'Deploy Azure Bastion (Terraform)'
description: 'Aprenda a implantar o Azure Bastion com Terraform e preparar acesso seguro às VMs sem expor portas públicas.'
date: 2025-02-08 08:30:00 -0300
categories: [Network]
tags: [Azure, Network, Bastion, Terraform, PaaS]
slug: 'Deploy-Bastion-Terraform'
image:
  path: /assets/img/covers/deploy-bastion-terraform.webp
  alt: 'Terraform inicializado para implantar o Azure Bastion'
---

Fala galera!👋

**Bem-vindo ao Blog Cloud Insights!** ☁️

Neste post, vamos explorar como realizar o Deploy do Azure Bastion via Terraform.

### Pré-Requisitos

Antes de começarmos nosso laboratório, verifique se você possui:

- Uma conta do Azure com uma assinatura ativa.

> Caso você não tenha uma assinatura, você pode criar uma Trial. Mais informações consulte <a href="https://azure.microsoft.com/en-us/" target="_blank" rel="noopener noreferrer">aqui</a>.
{: .prompt-tip }

- Um Service Principal (um tipo de identidade no Azure usada para autenticação) com permissionamento adequado.

> Obs.: Neste laboratório, o Service Principal precisa apenas da role **Contributor** na assinatura usada pelo Terraform. Não é necessário atribuir **Global Administrator** no Entra ID. Para saber mais sobre atribuição de permissões, consulte <a href="https://learn.microsoft.com/en-us/azure/role-based-access-control/role-assignments-portal" target="_blank" rel="noopener noreferrer">a documentação de RBAC do Azure</a>.
{:.prompt-info}

- Ter o VS Code instalado em seu sistema operacional Windows com as extensões Azure Terraform, Hashicorp Terraform e PowerShell.

> Caso não tenha o VS Code instalado, faça o download do instalador <a href="https://code.visualstudio.com/sha/download?build=stable&os=win32-x64" target="_blank" rel="noopener noreferrer">aqui</a>.
{:.prompt-info}

- Ter o Terraform instalado no seu computador.

> Caso não tenha o Terraform instalado, siga este <a href="https://cloudinsights.com.br/posts/Service-Principal-Terraform/#1-baixar-a-%C3%BAltima-vers%C3%A3o-do-execut%C3%A1vel-do-terraform-para-windows" target="_blank" rel="noopener noreferrer">procedimento</a>.
{:.prompt-info}

### 1. Criar a estrutura de arquivos

- Crie uma nova pasta e abra o VSCode "Visual Studio Code" nela para começar a configurar os recursos necessários.
  - Vamos estruturar os arquivos do projeto para iniciar a criação dos recursos com Terraform. Crie a estrutura de arquivos abaixo:

![Estrutura de arquivos do laboratório do Azure Bastion](/assets/img/Lab01-Bastion/Bastion-TF/FolderStructure2.png){: .shadow .rounded-10}

### 2. Iniciar a codificação dos arquivos

- Aqui vamos adicionar as informações do nosso ambiente no Azure.
  - *Precisaremos definir algumas variáveis de ambiente.*
- Adicione esse conteúdo no arquivo ***powershell-credentials-azure.ps1***.

```powershell
$env:ARM_CLIENT_ID = "Client ID do seu SPN" # Service Principal com a role Contributor na assinatura
$env:ARM_TENANT_ID = "O ID do seu Tenant no EntraID"
$env:ARM_SUBSCRIPTION_ID = "ID da sua assinatura"
$env:ARM_CLIENT_SECRET = "Secret do seu SPN" # Credencial usada pelo Terraform para autenticação
```

- Aqui vamos adicionar as informações do provider AzureRM. Adicione o conteúdo abaixo no arquivo ***provider.tf***.

```hcl
provider "azurerm" {
  # Configure the Azure Resource Manager provider
  features {} # Configuration options for the provider
}
```

- Aqui vamos adicionar as informações das versões mais recentes dos providers AzureRM e HTTP. Adicione o conteúdo abaixo no arquivo ***version.tf***.

```hcl
# Configure Terraform para usar os provedores necessários
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.19.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.5"
    }
  }
}
```

> *Se quiser consultar uma versão mais recente, pode buscar nos links a seguir <a href="https://registry.terraform.io/providers/hashicorp/azurerm/latest" target="_blank" rel="noopener noreferrer">**AzureRM Provider**</a> e <a href="https://registry.terraform.io/providers/hashicorp/http/latest" target="_blank" rel="noopener noreferrer">**HTTP-Provider**</a>*.
  {: .prompt-tip }

- Agora vamos iniciar a codificação dos recursos que precisamos fazer o deploy. Vamos iniciar com as tags. Elas são importantes para identificar os recursos no portal do Azure. Adicione o conteúdo abaixo no arquivo ***locals.tf***.

```hcl
# Tags padrões para os recursos criados pelo Terraform
locals {
  tags = {
    # Ambiente em que o recurso está sendo criado
    Environment = "Dev"
    # Nome do projeto que o recurso está sendo criado
    Project = "Bastion-Host"
    # Ferramenta que está gerenciando o recurso
    Managedby = "Terraform"
  }
}
```

- Agora vamos adicionar o código para criar um Resource-Group. Adicione o código abaixo no arquivo ***rg.tf***.

```hcl
# Crie um recurso do tipo azurerm_resource_group
# mais informações: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "rg-bastion-host" {
  name     = "rg-bastion-host"
  location = "East US 2"
  tags     = local.tags
}
```

- Agora vamos adicionar o código para criar uma Virtual Network. Adicione o conteúdo abaixo no arquivo ***vnet.tf***.

```hcl
# Crie um recurso do tipo azurerm_virtual_network
# mais informações: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.rg-bastion-host.name
  location            = azurerm_resource_group.rg-bastion-host.location
  address_space       = ["10.101.0.0/16"] # Espaço de endereçamento da VNet
  tags                = local.tags
}

# Crie um recurso do tipo azurerm_subnet
# mais informações: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "subnet" {
  name                              = "subnet"
  resource_group_name               = azurerm_resource_group.rg-bastion-host.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = ["10.101.10.0/24"] # Sub-rede criada na VNet
  private_endpoint_network_policies = "NetworkSecurityGroupEnabled"
}

# Crie um recurso do tipo azurerm_subnet para o Bastion-Host
# mais informações: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "bastion-subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.rg-bastion-host.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.101.50.0/26"]
}
```

> *Para mais informações sobre a Azure Bastion Subnet, consulte o link a seguir: <a href="https://learn.microsoft.com/en-us/azure/bastion/configuration-settings#subnet" target="_blank" rel="noopener noreferrer">**Azure Bastion subnet**</a>.*
  {: .prompt-tip }

- Agora vamos adicionar o código para criar um NSG (Network Security Group) e uma regra. Adicione o conteúdo abaixo no arquivo ***nsg.tf***.

```hcl
# Esse código faz uma solicitação HTTP para obter o endereço IP público da máquina que está executando o Terraform. É como perguntar "Qual é o meu IP?" e obter a resposta diretamente na sua configuração do Terraform.

data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

# Crie um recurso do tipo azurerm_network_security_group
# mais informações: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group
resource "azurerm_network_security_group" "nsg" {
  name                = "nsg"
  resource_group_name = azurerm_resource_group.rg-bastion-host.name
  location            = azurerm_resource_group.rg-bastion-host.location
  tags                = local.tags

  # permite que as requests sejam recebidas
  security_rule {
    name                       = "RDP-Inbound"
    description                = "Allow RDP Inbound"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = chomp(data.http.myip.response_body)
    destination_address_prefix = azurerm_windows_virtual_machine.vm-win-server.private_ip_address
  }
}

# Associe o NSG ao Subnet
# mais informações: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association
resource "azurerm_subnet_network_security_group_association" "association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
```

- Aqui vamos criar uma VM Windows Server para validar o acesso através do Bastion Host. Adicione o conteúdo abaixo no arquivo ***vm-win-server.tf***

> *Como o Bastion Host será utilizado como ponte de acesso seguro e criptografado para esta VM, não é necessário criar um IP público para a VM. O acesso será feito internamente através do Bastion Host.*
{:.prompt-info}

```hcl
# Cria uma interface de rede para a VM
resource "azurerm_network_interface" "vm-win-server-nic" {
  name                = "vm-win-server-nic"
  location            = azurerm_resource_group.rg-bastion-host.location
  resource_group_name = azurerm_resource_group.rg-bastion-host.name

  ip_configuration {
    name                          = "vm-win-server-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = local.tags
}

# Cria a VM com o Windows Server
resource "azurerm_windows_virtual_machine" "vm-win-server" {
  name                  = "vm-win-server"
  resource_group_name   = azurerm_resource_group.rg-bastion-host.name
  location              = azurerm_resource_group.rg-bastion-host.location
  size                  = "Standard_B2ms"
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = [azurerm_network_interface.vm-win-server-nic.id]
  tags                  = local.tags

  # Configura o disco do sistema operacional
  os_disk {
    caching              = "ReadWrite"
    disk_size_gb         = 128
    storage_account_type = "StandardSSD_LRS"
    name                 = "vm-win-server-os-disk"
  }

  # Configura a imagem do sistema operacional
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2025-datacenter-azure-edition"
    version   = "latest"
  }

  # Habilita o agente de provisionamento da VM
  provision_vm_agent = true

  # Configura o fuso horário da VM
  timezone = "E. South America Standard Time"

  # Habilita o hotpatching
  hotpatching_enabled = true

  # Configura o modo de patch
  patch_mode = "AutomaticByPlatform"

  # Habilita o TPM
  vtpm_enabled = true

  # Habilita o Secure Boot
  secure_boot_enabled = true
}
```

> A versão `latest` foi usada para simplificar o laboratório. Em ambientes de produção, fixe uma versão de imagem testada e validada para evitar mudanças inesperadas durante o `apply`.
{: .prompt-warning }

- Aqui vamos adicionar o código das nossas variáveis que iremos utilizar. Adicione o conteúdo abaixo no arquivo ***variables.tf***.

```hcl
# Variáveis para atribuir um usuário e senha para a Máquina Virtual Windows Server.
variable "admin_username" {
  description = "O nome de usuário para acessar a máquina virtual. Será usado para o acesso remoto via RDP."
  type        = string
  sensitive   = true
}

variable "admin_password" {
  description = "A senha para a máquina virtual. Será usada para o acesso remoto via RDP."
  type        = string
  sensitive   = true
}
```

> Em vez de adicionar os valores das variáveis no arquivo `variables.tf`, vamos adicioná-las como variáveis de ambiente ao executar o Terraform. Isso ajuda a manter dados sensíveis, como senhas, fora dos arquivos de configuração do Terraform.
{: .prompt-warning }

- Valide e utilize o exemplo abaixo para criar as variáveis de ambiente do username e password. No terminal do VSCode adicione essas linhas abaixo:

```powershell
# Adicione aqui seu usuário e senha para a Máquina Virtual Windows Server.
# Essas variáveis serão usadas para o acesso remoto via RDP.
$env:TF_VAR_admin_username="Adicione aqui seu usuário"
$env:TF_VAR_admin_password="Adicione aqui sua senha"
```

<center> Você pode validar a execução pelo exemplo abaixo: </center>
![Variáveis de usuário e senha da máquina virtual](/assets/img/Lab01-Bastion/Bastion-TF/User+Password-EnvironmentVariables.png){: .shadow .rounded-10}

- Aqui vamos adicionar alguns outputs para facilitar a visualização dos resultados do deploy. Adicione o conteúdo abaixo no arquivo ***output.tf***.

```hcl
# Saída do endereço IP privado da interface de rede da máquina virtual
output "private_ip" {
  value = azurerm_network_interface.vm-win-server-nic.private_ip_address
}

# Saída do nome da máquina virtual
output "vm_name" {
  value = azurerm_windows_virtual_machine.vm-win-server.name
}
```

- Por fim, vamos adicionar o código que vai criar o Azure Bastion. Adicione o conteúdo abaixo no arquivo ***bastionhost.tf***.

```hcl
# Cria um recurso do tipo public_ip para ser usado pelo Bastion
# mais informações: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "bastion-pip" {
  name                = "bastion-pip"
  location            = azurerm_resource_group.rg-bastion-host.location
  resource_group_name = azurerm_resource_group.rg-bastion-host.name
  allocation_method   = "Static"
  tags                = local.tags
}

# Cria um recurso do tipo azure_bastion_host
# mais informações: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/bastion_host
resource "azurerm_bastion_host" "bastion" {
  name                = "bastion"
  location            = azurerm_resource_group.rg-bastion-host.location
  resource_group_name = azurerm_resource_group.rg-bastion-host.name
  sku                 = "Standard"

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion-subnet.id
    public_ip_address_id = azurerm_public_ip.bastion-pip.id
  }
}
```

### 3. Inicializar o Terraform

Já com todos os arquivos codificados, vamos iniciar o Terraform. No terminal do VSCode, digite o comando abaixo. O comando `terraform init` inicializa um novo ou existente diretório do Terraform configurando o ambiente, baixando os plugins e preparando o estado para implantação.

```powershell
terraform init
```

![Inicialização do Terraform no laboratório do Bastion](/assets/img/Lab01-Bastion/Bastion-TF/TerraformInit2.png){: .shadow .rounded-10}

### 4. Validar se a configuração está correta

- Nesta etapa vamos executar o `terraform validate` para verificar se os arquivos de configuração criados estão corretos em termos de sintaxe e lógica. Ele não faz alterações nos recursos, apenas valida a configuração. É útil para identificar erros antes de executar o plano *terraform plan*. 😉

```powershell
terraform validate
```

![Validação da configuração Terraform do Bastion](/assets/img/Lab01-Bastion/Bastion-TF/TerraformValidate2.png){: .shadow .rounded-10}

#### 5. Validar a formatação dos arquivos

- Agora vamos executar o `terraform fmt`. Este comando formata os arquivos de configuração para seguir um estilo de código consistente e legível. Corrige indentação, alinhamento e outros aspectos de formatação conforme as convenções do Terraform. É uma boa prática usar esse comando regularmente para manter a base de código organizada.

```powershell
terraform fmt
```

![Formatação dos arquivos Terraform do laboratório](/assets/img/Lab01-Bastion/Bastion-TF/TerraformFMT2.png){: .shadow .rounded-10}

#### 6. Criar as variáveis de ambiente para conectar ao Azure

- Neste passo com o powershell aberto, dentro do VSCode, execute o comando abaixo. Ele vai executar o arquivo ***powershell-credentials-azure.ps1***.

```powershell
.\powershell-credentials-azure.ps1
```

<center> Notem na figura que eu validei se as variáveis foram adicionadas corretamente </center>
![Variáveis de autenticação do Azure no terminal](/assets/img/Lab01-Bastion/Bastion-TF/EnvironmentVariables2.png){: .shadow .rounded-10}

#### 7. Criar o plano de execução

- Seguido todos esses passos, agora vamos criar um plano, execute o comando `terraform plan -out bastionhost.out`. Ele cria um plano de execução e armazena em um arquivo. O arquivo my_vm-lnx.out é criado para revisar o que será feito sem aplicar as mudanças.

```powershell
terraform plan -out bastionhost.out
```


> Na figura acima, estou apresentando somente a quantidade de recursos que serão criados. Isso é feito para proteger a segurança dos dados e evitar exposição desnecessária de informações sensíveis, como o ID da assinatura onde os recursos serão criados. Note que ele já me traz as informações de outputs que criamos logo acima.
{: .prompt-danger }

#### 8. Fazer o deploy dos recursos

- Agora, com o plano já executado, já sabemos quais recursos serão criados. Vamos executar o `terraform apply bastionhost.out`.
  - Esse comando aplica as mudanças especificadas no arquivo de plano gerado pelo comando `terraform plan`.

```powershell
terraform apply bastionhost.out
```

![Aplicação do Terraform para criar o Azure Bastion](/assets/img/Lab01-Bastion/Bastion-TF/TerraformApply.png){: .shadow .rounded-10}

#### 9. Listar recursos criados pelo Terraform

- Vamos executar o comando `terraform state list`. Ele é utilizado para listar todos os recursos gerenciados pelo estado do Terraform.
  - Este comando exibe uma lista de recursos que foram criados, atualizados ou destruídos pelo Terraform e que estão sendo rastreados no arquivo tfstate.

```powershell
terraform state list
```

![Recursos do laboratório listados no estado do Terraform](/assets/img/Lab01-Bastion/Bastion-TF/TerraformState.png){: .shadow .rounded-10}

#### 10. Validar recursos criados no portal do Azure

- A estrutura de recursos criada pode ser vista na figura abaixo.

![Recursos do laboratório no grupo de recursos](/assets/img/Lab01-Bastion/Bastion-TF/RG.png){: .shadow .rounded-10}

- Os detalhes da VM criada podem ser vistos na figura abaixo.

![VM criada no portal do Azure](/assets/img/Lab01-Bastion/Bastion-TF/CreateVM.png){: .shadow .rounded-10}

- Página de visão geral do Azure Bastion.

![Azure Bastion criado no portal do Azure](/assets/img/Lab01-Bastion/Bastion-TF/BastionHost.png){: .shadow .rounded-10}

- A regra de segurança de rede (NSG) foi criada com origem somente meu IP público e destino o IP da VM, como visto na figura abaixo.

![Regra de segurança criada para acesso à VM](/assets/img/Lab01-Bastion/Bastion-TF/NSG-Rule.png){: .shadow .rounded-10}


#### 11. Acessar a VM com o Azure Bastion

- Nesta parte, com o usuário e senha configurados como variáveis de ambiente, podemos conectar à VM Windows Server utilizando o protocolo RDP através do Azure Bastion Host.

  - Dentro do portal do Azure, localize a VM, clique em **Visão geral** e depois em **Bastion**. Você pode conferir o passo a passo abaixo:

![Acesso à VM pelo Azure Bastion](/assets/img/Lab01-Bastion/Bastion-TF/VM-Access-Bastion.webp){: .shadow .rounded-10}

#### 12. Remover recursos criados com terraform destroy

- Agora que nós criamos nossos recursos, testamos, vamos fazer a remoção deles. O comando `terraform destroy` é utilizado para destruir todos os recursos gerenciados pelo Terraform em sua configuração. Isso significa que ele apagará todos os recursos da infraestrutura que foram criados ou gerenciados pelo Terraform.

> Esse comando é útil quando você deseja desfazer todas as mudanças aplicadas ou quando precisa limpar o ambiente.
{: .prompt-tip }

![Execução do terraform destroy no laboratório](/assets/img/Lab01-Bastion/Bastion-TF/TerraformDestroy.png){: .shadow .rounded-10}
![Confirmação da remoção dos recursos do laboratório](/assets/img/Lab01-Bastion/Bastion-TF/TerraformDestroy2.png){: .shadow .rounded-10}

> É importante lembrar que o comando terraform destroy apaga todos os recursos gerenciados pelo Terraform, então use-o com cautela, especialmente em ambientes de produção. Sempre revise o plano de destruição antes de confirmar para garantir que você não está apagando algo por engano.
{: .prompt-danger }

### Resumo:

Este artigo detalha o processo de implantação do Azure Bastion utilizando o Terraform. O Azure Bastion é um serviço que proporciona acesso seguro e contínuo às suas máquinas virtuais diretamente pelo portal do Azure, eliminando a necessidade de endereços IP públicos ou configurações complexas de VPN. Ao longo deste guia, abordamos os pré-requisitos necessários, a estruturação dos arquivos de configuração e os comandos essenciais para efetuar o deploy de forma eficiente e segura.

### Conclusão:

A implementação do Azure Bastion via Terraform automatiza e simplifica o processo de provisionamento de acesso seguro às VMs no Azure. Ao definir a infraestrutura como código, garantimos consistência, repetibilidade e facilidade de manutenção no ambiente. Este método não só reduz a probabilidade de erros manuais como também agiliza o processo de implantação, tornando-o mais robusto e escalável.

### Próximos Passos:

Para aprofundar seus conhecimentos e aprimorar a segurança e eficiência do seu ambiente Azure, considere os seguintes passos:

1. **Explorar Configurações Avançadas do Azure Bastion**: Investigue recursos adicionais, como a integração com o Azure Active Directory e o uso de autenticação multifator para reforçar a segurança.

2. **Automatizar Implantações com Pipelines CI/CD**: Implemente pipelines de Integração Contínua/Entrega Contínua para automatizar o deploy das configurações do Terraform, garantindo atualizações consistentes e controladas.

3. **Monitorar e Registrar Acessos**: Configure o Azure Monitor e o Azure Log Analytics para acompanhar e registrar as atividades de acesso através do Bastion, facilitando auditorias e detecção de anomalias.

4. **Manter-se Atualizado com as Melhores Práticas de Segurança**: Revise regularmente as diretrizes de segurança do Azure e do Terraform para assegurar que suas implementações estejam alinhadas com as práticas recomendadas mais recentes.

Seguindo esses passos, você estará no caminho certo para otimizar a gestão e a segurança do seu ambiente de nuvem no Azure.

*Essas são apenas algumas ideias para aprimorar sua infraestrutura com Terraform! Continue explorando novas configurações e torne seu ambiente ainda mais seguro e automatizado.*

Até a próxima!! 😉

![Logo do Cloud Insights](/assets/img/02/cloudinsights3.png){: .shadow .rounded-10}

#CloudInsights #Azure #Tech #Cloud #Security #Network #Terraform #InfraAsCode #PaaS #Bastion

---

[![Build and Deploy](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml/badge.svg)](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml)
---
layout: post
title: 'Crie VMs Windows Server no Azure em Minutos com Terraform'
description: 'Aprenda a criar uma VM Windows Server 2025 no Azure com Terraform, incluindo rede, NSG e autenticação.'
date: 2025-01-27 08:30:00 -0300
categories: [IaaS]
tags: [Azure, IaaS, WindowsServer, Terraform, InfraAsCode]
slug: 'Deploy-VM-WindowsServer-Terraform'
image:
  path: /assets/img/covers/deploy-vm-windowsserver-terraform.webp
  alt: 'Terraform inicializado para criar uma VM Windows Server no Azure'
---

Fala galera!👋

**Bem-vindo ao blog Cloud Insights!** ☁️

Neste post, vamos explorar como automatizar a implantação (deploy) de uma máquina virtual com ***Windows Server*** no Azure usando Terraform. Embora o processo seja aplicável a qualquer versão do sistema operacional Windows Server, neste post faremos o deploy específico do ***Windows Server 2025***. A automação desse processo oferece vários benefícios, como:

- Consistência: Elimina erros manuais ao criar recursos no Azure.
- Eficiência: Reduz o tempo de configuração e implantação.
- Versionamento: Com o Terraform, você pode rastrear e controlar alterações no ambiente de infraestrutura.

> *Nota: Este tutorial utiliza o Windows Server 2025, que ainda se encontra em estágio de pré-lançamento no momento da redação deste artigo. Certifique-se de verificar a disponibilidade da versão para o seu ambiente antes de seguir o passo a passo.*
{:.prompt-info}

### Máquina Virtual ou Virtual Machine

**O que é**:
Uma VM (Virtual Machine) é um serviço que oferece servidores virtuais sob demanda na nuvem. Esses servidores podem ser configurados para executar sistemas operacionais como Windows ou Linux, além de aplicações específicas. É como ter um servidor físico, mas sem a necessidade de gerenciar o hardware diretamente, já que tudo é virtualizado.

## Por que usar uma VM?

- **💰 Corte de Custos Fixos**: Substitua grandes investimentos em servidores físicos por custos baseados no uso. Por exemplo, crie VMs para testes temporários e pague apenas pelo tempo utilizado.
- **⚙️ Menos Complexidade**: O Azure cuida da infraestrutura básica, como atualizações e segurança, permitindo que você se concentre em desenvolver e entregar serviços.
- **🌍 Globalização Simples**: Garanta baixa latência para seus usuários ao implantar VMs em data centers ao redor do mundo, atendendo também a requisitos locais de conformidade.
- **📈 Backup e Escalabilidade**: Ajuste os recursos rapidamente para atender à demanda. Seja aumentando capacidade durante a Black Friday ou replicando ambientes para recuperação de desastres, as VMs facilitam a adaptação.

## Para que serve

1. **Execução de Aplicações**: Ideal para hospedar aplicações empresariais que exigem um servidor dedicado.
2. **Ambiente de Testes**: Permite a criação de ambientes isolados para testes de software e experimentos.
3. **Armazenamento Temporário**: Processar ou hospedar dados em períodos curtos sem ocupar recursos físicos.
4. **Ambiente de Desenvolvimento**: Para equipes de desenvolvimento que precisam de máquinas personalizadas.

### Cenários de Uso

1º **Desenvolvimento e Teste de Software**:

- Criar ambientes de desenvolvimento semelhantes aos de produção.
- Testar diferentes sistemas operacionais ou configurações.

2º **Hospedagem de Aplicações Web**:

- Hospedar websites ou APIs com alta disponibilidade.
- Usar VMs como backend para aplicações críticas.

3º **Computação Intensiva**:

- Processamento de big data, análise de dados ou execução de simulações complexas.
- Treinamento de modelos de Machine Learning.

4º **Sistemas Herdados**:

- Migrar sistemas legados (on-premises) para a nuvem sem necessidade de reformulação imediata.

5º **Extensão de Data Centers**:

- Usar VMs como uma extensão de data centers locais para lidar com demandas sazonais ou picos de carga.

6º **Recuperação de Desastres**:

- Configurar VMs como backup de infraestrutura crítica para garantir continuidade em caso de falhas.

### Pré-Requisitos

Antes de começarmos nosso laboratório, verifique se você possui:

- Uma conta do Azure com uma assinatura/subscription ativa.

> Caso você não tenha uma subscription, você pode criar uma Trial. Mais informações consulte <a href="https://azure.microsoft.com/en-us/" target="_blank">aqui</a>.
{: .prompt-tip }

- Um Service Principal (um tipo de identidade no Azure usada para autenticação) com permissionamento adequado.

> Obs.: Aqui estou utilizando um Service Principal com permissão de "Global Administrator" no Entra ID e com a permissao de Contributor na minha assinatura. Para saber como adicionar uma permissão privilegiada em uma conta, consulte <a href="https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/manage-roles-portal?tabs=admin-center" target="_blank">aqui</a>.
{:.prompt-info}

- Ter o VSCode Instalado em seu Sistema Operacional Windows com as extensões Azure Terraform, Hashicorp Terraform e PowerShell.

> Caso não tenha o VSCode Instalado, faça o Download do instalador <a href="https://code.visualstudio.com/sha/download?build=stable&os=win32-x64" target="_blank">aqui</a>.
{:.prompt-info}

- Ter o Terraform instalado no seu computador.

> Caso não tenha o Terraform instalado, siga este <a href="https://cloudinsights.com.br/posts/Service-Principal-Terraform/#1-primeiro-passo-aqui-%C3%A9-realizar-o-download-da-%C3%BAltima-vers%C3%A3o-do-execut%C3%A1vel-do-terraform-para-windows" target="_blank">procedimento</a>.
{:.prompt-info}

- Importante: Certifique-se de que sua Subscription do Azure oferece suporte à versão ***Windows Server 2025***. Caso contrário, ajuste o exemplo para uma versão suportada, como ***Windows Server 2022***.


### 1. Criar estrutura de Arquivos

- Crie uma nova pasta e abra o VSCode "Visual Studio Code" nela para começar a configurar os recursos necessários.
  - Vamos estruturar os arquivos do projeto para iniciar a criação dos recursos com Terraform. Crie a estrutura de arquivos a abaixo:

![Folder-Structure](/assets/img/Lab03-VMWindowsServer/FolderStructure.png){: .shadow .rounded-10}

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
      version = "4.16.0"
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
    Project = "VM-WindowsServer"
    # Ferramenta que esta gerenciando o recurso
    Managedby = "Terraform"
  }
}
```

- Agora vamos adicionar o código para criar um Resource-Group. Adicione o código abaixo no arquivo ***rg.tf***.

```hcl
# Crie um recurso do tipo resource_group
# mais informacoes: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "rg-vm-win" {
  name     = "rg-vm-win"
  location = "East US 2"
  tags     = local.tags
}
```

- Agora vamos adicionar o código para criar uma Virtual Network. Adicione o conteúdo abaixo no arquivo ***vnet.tf***.

```hcl
# Crie um recurso do tipo virtual_network
# mais informacoes: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  resource_group_name = azurerm_resource_group.rg-vm-win.name
  location            = azurerm_resource_group.rg-vm-win.location
  address_space       = ["10.101.0.0/16"] # Espaco de enderecamento da VNet
  tags                = local.tags
}

# Crie um recurso do tipo subnet
# mais informacoes: https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet
resource "azurerm_subnet" "subnet" {
  name                              = "subnet"
  resource_group_name               = azurerm_resource_group.rg-vm-win.name
  virtual_network_name              = azurerm_virtual_network.vnet.name
  address_prefixes                  = ["10.101.10.0/24"] # Sub-rede criada na VNet
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
  resource_group_name = azurerm_resource_group.rg-vm-win.name
  location            = azurerm_resource_group.rg-vm-win.location
  tags                = local.tags

  # Permite que as requisições sejam recebidas somente a partir do meu IP público, garantindo que apenas eu consiga acessar a VM.
  security_rule {
    name                       = "RDPInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = chomp(data.http.myip.response_body)
    destination_address_prefix = azurerm_windows_virtual_machine.vm-win-server.private_ip_address # Aqui no destino você garante que a origem vai conseguir comunicação na porta 3389 somente no IP Privado da VM que vamos criar.
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
# Variáveis para atribuir um usuário e senha para a Maquina Virtual Windows Server.
variable "admin_username" {
  description = "O nome de usuário para acessar a maquina virtual. Será usado para o acesso remoto via RDP."
  type        = string
}

variable "admin_password" {
  description = "A senha para a máquina virtual. Será usada para o acesso remoto via RDP."
  type        = string
  sensitive   = true
}
```

- Agora vamos adicionar o código para a estrutura da VM. Adicione o conteúdo abaixo no arquivo ***vm-win-server.tf***.

```hcl
# Cria um IP publico para a VM
resource "azurerm_public_ip" "vm-win-server-pip" {
  name                = "vm-win-server-pip"
  resource_group_name = azurerm_resource_group.rg-vm-win.name
  location            = azurerm_resource_group.rg-vm-win.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

# Cria uma interface de rede para a VM
resource "azurerm_network_interface" "vm-win-server-nic" {
  name                = "vm-win-server-nic"
  location            = azurerm_resource_group.rg-vm-win.location
  resource_group_name = azurerm_resource_group.rg-vm-win.name

  ip_configuration {
    name                          = "vm-win-server-ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm-win-server-pip.id
  }
  tags = local.tags
}

# Cria a VM com o Windows Server
resource "azurerm_windows_virtual_machine" "vm-win-server" {
  name                  = "vm-win-server"
  resource_group_name   = azurerm_resource_group.rg-vm-win.name
  location              = azurerm_resource_group.rg-vm-win.location
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

  # Configura o fuso horario da VM
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

- Por fim, vamos adicionar alguns outputs para facilitar a visualização dos resultados do deploy. Adicione o conteúdo abaixo no arquivo ***output.tf***.

```hcl
output "public_ip" {
  value = azurerm_public_ip.vm-win-server-pip.ip_address
}

output "private_ip" {
  value = azurerm_network_interface.vm-win-server-nic.private_ip_address
}

output "vm_name" {
  value = azurerm_windows_virtual_machine.vm-win-server.name
}
```

![Terraform-Output](/assets/img/Lab03-VMWindowsServer/TerraformOutput.png){: .shadow .rounded-10}

### 4. Inicializar o Terraform

 Já com todos os arquivos codificados, vamos iniciar o Terraform. No terminal do VSCode, digite o comando abaixo. O comando `terraform init` inicializa um novo ou existente diretório do Terraform configurando o ambiente, baixando os plugins e preparando o estado para implantação.

```powershell
terraform init
```

![Terraform-Init](/assets/img/Lab03-VMWindowsServer/TerraformInit.png){: .shadow .rounded-10}

### 5. Validar se a configuração está Correta

- Nesta etapa vamos executar o `terraform validate` para verificar se os arquivos de configuração criados estão corretos em termos de sintaxe e lógica. Ele não faz alterações nos recursos, apenas valida a configuração. É útil para identificar erros antes de executar o plano *terraform plan*. 😉

```powershell
terraform validate
```

![Terraform-Validate](/assets/img/Lab03-VMWindowsServer/TerraformValidate.png){: .shadow .rounded-10}

#### 6. Validar a formatação dos Arquivos

- Agora vamos executar o `terraform fmt`. Este comando formata os arquivos de configuração para seguir um estilo de código consistente e legível. Corrige indentação, alinhamento e outros aspectos de formatação conforme as convenções do Terraform. É uma boa prática usar esse comando regularmente para manter a base de código organizada.

```powershell
terraform fmt
```

![Terraform-FMT](/assets/img/Lab03-VMWindowsServer/TerraformFMT.png){: .shadow .rounded-10}

#### 7. Criar as variáveis de ambiente para ser possivel se conectar na Azure

- Neste passo com o powershell aberto, dentro do VSCode, execute o comando abaixo. Ele vai executar o arquivo ***powershell-credencials-azure.ps1***.

```powershell
.\powershell-credencials-azure.ps1
```

<center> Notem na figura que eu validei se as variáveis foram adicionadas corretamente </center>
![Set-Azure-Variables](/assets/img/Lab02-ServicePrincipal/SetVariaveisAzure.png){: .shadow .rounded-10}

- Aqui vamos adicionar as variavies de ambiente informando o usuario e senha da Virtual Machine. Adicione o comando abaixo em seu terminal do PowerShell.

```powershell
$env:TF_VAR_admin_username="admin.cloudinsights"

$env:TF_VAR_password="Crie uma senha e adicione aqui"
```

![Set-VM-Variables](/assets/img/Lab03-VMWindowsServer/VariaveisUserPass.png){: .shadow .rounded-10}

#### 8. Criar plano de Execução

- Seguido todos esses passos, agora vamos criar um plano, execute o comando `terraform plan -out my_vm.out`. Ele cria um plano de execução e armazena em um arquivo. O arquivo my_vm.out é criado para revisar o que será feito sem aplicar as mudanças.

```powershell
terraform plan -out my_vm.out
```

![Terraform-Plan](/assets/img/Lab03-VMWindowsServer/TerraformPlan.png){: .shadow .rounded-10}

> Na figura acima, estou apresentando somente a quantidade de recursos que serão criados. Isso é feito para proteger a segurança dos dados e evitar exposição desnecessária de informações sensíveis, como o ID da subscription onde os recursos serão criados. Note que ele já me traz as informações de outputs que criamos logo acima.
{: .prompt-danger }

#### 8. Fazer o deploy dos Recursos

- Agora, com o plano já executado, já sabemos quais recursos serão criados. Vamos executar o `terraform apply my_vm.out`.
  - Esse comando aplica as mudanças especificadas no arquivo de plano gerado pelo comando `terraform plan`.

```powershell
terraform apply my_vm.out
```

![Terraform-Apply](/assets/img/Lab03-VMWindowsServer/TerraformApply+Outputs.png){: .shadow .rounded-10}

<!-- #### 9. Validar as informações no Output

- Voçê pode executar o comando *terraform output*. Ele é utilizado para exibir os valores das variáveis de saída definidas no seu arquivo de configuração do Terraform. Essas variáveis de saída permitem que você acesse e use os valores gerados pela execução do plano de Terraform, como endereços IP, IDs de recursos, URLs e outras informações importantes.

```powershell
terraform output
```

![Terraform-Output](/assets/img/Lab02-ServicePrincipal/terraform%20output.png){: .shadow .rounded-10}

 -->

#### 09. Listar recursos criados pelo Terraform

- Vamos executar o comando `terraform state list`. Ele é utilizado para listar todos os recursos gerenciados pelo estado do Terraform.
  - Este comando exibe uma lista de recursos que foram criados, atualizados ou destruídos pelo Terraform e que estão sendo rastreados no arquivo tfstate.

```powershell
terraform state list
```

![Terraform-State-List](/assets/img/Lab03-VMWindowsServer/TerraformStateList.png){: .shadow .rounded-10}

#### 11. Validar recursos criados no Portal Azure

- A estrutura de recursos criada pode ser vista na figura abaixo.

![RG-Recursos](/assets/img/Lab03-VMWindowsServer/RG+Recursos.png){: .shadow .rounded-10}

- Os detalhes da VM criada podem ser vistos na figura abaixo.

![VM-Portal](/assets/img/Lab03-VMWindowsServer/ValidaçãoVMCriadanoPortal.png){: .shadow .rounded-10}

- A regra de segurança de rede (NSG) foi criada com origem somente meu IP público e destino o IP da VM, como visto na figura abaixo.

![NSG-Rule](/assets/img/Lab03-VMWindowsServer/NSGRule.png){: .shadow .rounded-10}


#### 12. Acessar VM criada

- Nesta parte, com o usuario e senha em mãos, podemos fazer o teste de acesso à VM através do ***RDP - Remote Desktop***.

![VM-Access](/assets/img/Lab03-VMWindowsServer/AcessoWindowsServer.png){: .shadow .rounded-10}

#### 12. Remover recursos criados com Terraform Destroy

- Agora que nós criamos a VM, testamos, vamos fazer a remoção dela. O comando `terraform destroy` é utilizado para destruir todos os recursos gerenciados pelo Terraform em sua configuração. Isso significa que ele apagará todos os recursos da infraestrutura que foram criados ou gerenciados pelo Terraform.

> Esse comando é útil quando você deseja desfazer todas as mudanças aplicadas ou quando precisa limpar o ambiente.
{: .prompt-tip }

![Terraform-Destroy](/assets/img/Lab03-VMWindowsServer/TerraformDestroy1.png){: .shadow .rounded-10}
![Terraform-Destroy2](/assets/img/Lab03-VMWindowsServer/TerraformDestroy2.png){: .shadow .rounded-10}

> É importante lembrar que o comando terraform destroy apaga todos os recursos gerenciados pelo Terraform, então use-o com cautela, especialmente em ambientes de produção. Sempre revise o plano de destruição antes de confirmar para garantir que você não está apagando algo por engano.
{: .prompt-danger }

#### 13. Segurança e Boas Práticas

**Armazenamento Seguro de Credenciais**: É recomendável usar o "*Azure Key Vault*" para armazenar informações sensíveis, como Senhas, IDs de cliente, segredos e certificados. Para integrá-lo ao Terraform, use a <a href="https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret" target="_blank">provider oficial do Azure</a>. Isso garante que as credenciais sejam acessadas de forma segura e centralizada.

**Exemplo:**

```hcl
data "azurerm_key_vault_secret" "example" {
  name         = "admin-passwork"
  key_vault_id = azurerm_key_vault.example.id
}
```
**Rotação de Secrets**: Configure políticas de rotação periódica de segredos no Azure Key Vault ou automatize esse processo para minimizar riscos de segurança.

### Conclusão

Implantar uma máquina virtual Windows Server 2025 no Azure utilizando Terraform simplifica o processo de gerenciamento e escalabilidade da infraestrutura. Com as instruções e exemplos fornecidos, você pode automatizar a criação e configuração de VMs, garantindo consistência e eficiência em suas operações.

### Resumo

Neste artigo, abordamos como utilizar o Terraform para implantar uma máquina virtual (VM) Windows Server 2025 no Azure. Explicamos os conceitos básicos e fornecemos um exemplo prático, detalhando cada etapa, desde a configuração inicial do Terraform até a criação e configuração da VM. Destacamos a importância de uma gestão eficiente e consistente da infraestrutura por meio da automação e da infraestrutura como código (IaC).

### Próximos Passos

Para aprofundar seu conhecimento e expandir as possibilidades de automação com Terraform e Azure, considere os seguintes passos:

**Aprimorar a Segurança**: Adicione regras de firewall específicas, configure grupos de segurança de rede (NSGs) e implemente autenticação multifator (MFA) para melhorar a segurança.

**Gerenciamento de Configuração**: Utilize ferramentas como Ansible, Chef ou Puppet para gerenciar configurações de VMs após a criação.

**Automatização Contínua**: Integre o Terraform com pipelines de CI/CD, como Azure DevOps ou GitHub Actions, para automações contínuas e implantação de infraestrutura como código (IaC).

**Monitoramento e Logs**: Configure Azure Monitor e Log Analytics para monitorar o desempenho das VMs e obter insights detalhados.

**Otimização de Custos**: Use Azure Cost Management para monitorar e otimizar os custos relacionados à sua infraestrutura, garantindo eficiência econômica.

**Backup e Recuperação**: Implemente soluções de backup e recuperação para garantir a disponibilidade e integridade dos dados.

Seguir esses passos ajudará a melhorar a segurança, eficiência e gestão contínua da sua infraestrutura no Azure, permitindo uma abordagem mais robusta e profissional na automação e gerenciamento de seus recursos.

Até a próxima!! 😉

![resource-group](/assets/img/02/cloudinsights3.png){: .shadow .rounded-10}

#CloudInsights #Azure #Tech #Cloud #Security #Network #Terraform #EntraID

---

[![Build and Deploy](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml/badge.svg)](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml)

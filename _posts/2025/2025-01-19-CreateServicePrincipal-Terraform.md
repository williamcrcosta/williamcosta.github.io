---
layout: post
title: 'Service Principal com Terraform'
description: 'Aprenda a criar um Service Principal com Terraform para autenticar automações no Azure.'
date: 2025-01-19 08:30:00 -0300
categories: [Identity]
tags: [Azure, Identity, EntraID, Terraform]
slug: 'Service-Principal-Terraform'
image:
  path: /assets/img/covers/service-principal-terraform.webp
  alt: 'Service Principal e automação no Azure'
---

Fala galera!👋

**Bem-vindo ao Blog Cloud Insights!** ☁️

Em nosso primeiro post de 2025, vamos explorar como realizar a criação de um Service Principal com Terraform.

### Service Principal

**O que é**:
No contexto do **Microsoft Entra ID**, um Service Principal é uma identidade que pode ser atribuída a aplicações, serviços ou automações para interagir com recursos no Azure. Ele atua como uma "conta de serviço" que oferece permissões específicas para executar tarefas sem depender de uma identidade humana.

## Por que usar um Service Principal?

Utilizar um Service Principal no Azure possibilita a automação de processos com segurança, assegura o controle de acesso baseado no princípio de menor privilégio e facilita a integração com ferramentas de DevOps e scripts de infraestrutura, promovendo eficiência e governança.

## Para que serve

- **Autenticação Automatizada**: Permite que aplicações ou scripts interajam com o Azure de forma segura, usando autenticação baseada em credenciais ou certificados.
- **Segurança e Controle**: Garante que o acesso a recursos seja limitado ao estritamente necessário, seguindo os princípios de <a href="https://learn.microsoft.com/en-us/azure/role-based-access-control/best-practices" target="_blank">*Least Privilege*</a>.
- **Integração com Ferramentas de DevOps**: É amplamente usado em pipelines CI/CD para deploys, atualizações e configurações automáticas.

### Cenários de Uso

- **Deploy de Infraestrutura com Terraform**: No Terraform, o Service Principal permite autenticar e executar operações no Azure para criar, atualizar ou destruir recursos de forma programática.
- **Execução de Workloads Automatizadas**: Usado por aplicações que precisam acessar APIs ou recursos no Azure, como bancos de dados, filas ou serviços de armazenamento.
- **Integração com Ferramentas de Terceiros**: Muitas ferramentas, como GitHub Actions, Jenkins ou Ansible, usam um Service Principal para se conectar ao Azure.
- **Segurança em Ambientes Multi-Tenant**: Facilita o gerenciamento de acessos específicos para serviços em ambientes multi-tenant.

### Pré-Requisitos

Antes de começarmos nosso laboratório, verifique se você possui:

- Uma conta do Azure com uma assinatura/subscription ativa.

> Caso você não tenha uma subscription, você pode criar uma Trial. Mais informações consulte [aqui](https://azure.microsoft.com/en-us/).
{: .prompt-tip }

- Um Service Principal com permissionamento adequado.

> Obs.: Aqui estou utilizando um Service Principal com permissão de "Global Administrator" no EntraID. Para saber como adicionar uma permissão privilegiada em uma conta, consulte <a href="https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/manage-roles-portal?tabs=admin-center" target="_blank">aqui</a>.
{:.prompt-info}

- Ter o VSCode Instalado em seu Sistema Operacional Windows com as extensões Azure Terraform e Hashicorp Terraform.

> *Caso não tenha o VSCode Instalado, faça o Download do instalador [aqui](https://code.visualstudio.com/sha/download?build=stable&os=win32-x64)*.
{:.prompt-info}

### 1. Primeiro passo aqui é realizar o download da última versão do executável do Terraform para Windows

- Acesse a página da <a href="https://developer.hashicorp.com/terraform/" target="_blank">Hashicorp</a> para fazer o download do pacote, depois disso salve o pacote na pasta Downloads e extraia o conteudo. Em seguida crie um novo diretório no disco C com nome "terraform" e adicione o conteudo extraído lá.

  - *Acompanhe o passo-a-passo abaixo*
![Download-TF](/assets/img/Lab02-ServicePrincipal/DownloadTFE-Configure.webp){: .shadow .rounded-10}

### 2. Definir variáveis de ambiente

- Neste passo vamos definir variáveis de ambiente. Abra o PowerShell ISE como administrator e execute os comandos abaixo.

````powershell
# Aqui vamos definir as variáveis de ambiente do usuário

#Este comando obtém o valor atual da variável de ambiente *Path* para o usuário e o armazena na variável $oldPath
$oldPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)

#Este comando adiciona o caminho C:\terraform ao valor atual de $oldPath e armazena o resultado na variável $newPath.
$newPath = $oldPath + ";C:\terraform"

#Este comando define a variável de ambiente *Path* do usuário para o novo valor contido em $newPath.
[System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::User)

# Agora vamos definir as variáveis de ambiente do Sistema

# Este comando obtém o valor atual da variável de ambiente *Path* para o sistema (máquina) e o armazena na variável $oldPath.
$oldPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Este comando adiciona o caminho C:\terraform ao valor atual de $oldPath e armazena o resultado na variável $newPath.
$newPath = $oldPath + ";C:\terraform"

# Este comando define a variável de ambiente *Path* do sistema para o novo valor contido em $newPath.
[System.Environment]::SetEnvironmentVariable("Path", $newPath, [System.EnvironmentVariableTarget]::Machine)
````

- Agora vamos verificar se as variáveis foram criadas.

````powershell
# Este comando obtém e exibe o valor atual da variável de ambiente Path para o sistema (máquina).
[System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Este comando obtém e exibe o valor atual da variável de ambiente Path para o sistema (máquina).
[System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
````

![Set-Variables](/assets/img/Lab02-ServicePrincipal/SetVariaveis.png){: .shadow .rounded-10}

> Esses comandos ajudam a gerenciar e verificar as variáveis de ambiente no Windows. Mais informações consulte os links a seguir:

- [Set (environment variable) - Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/set_1?form=MG0AV3). Esta página explica como usar o comando set para definir, exibir ou remover variáveis de ambiente no Windows
- [About_Environment_Variables - PowerShell - Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.4&form=MG0AV3). Esta página fornece informações detalhadas sobre como acessar e gerenciar variáveis de ambiente no PowerShell.
{: .prompt-tip }

*Agora que finalizamos as configurações iniciais no Windows, vamos preparar nosso ambiente de trabalho.*

### 3. Criar uma nova pasta  e estrutura de Arquivos

- Crie uma nova pasta e abra o VSCode nela para começar a configurar os recursos necessários.
- Vamos estruturar os arquivos do projeto para iniciar a criação dos recursos no Terraform.

![Folder-Structure](/assets/img/Lab02-ServicePrincipal/File-Structure.png){: .shadow .rounded-10}

### 4. Vamos iniciar codificando nossos arquivos

- Aqui vamos adicionar as informações do nosso ambiente no Azure.
  - *Precisaremos setar mais algumas variáveis de ambiente.*
- Adicione esse conteudo no arquivo *powershell-credencials-azure.ps1*.

```powershell
$env:ARM_CLIENT_ID = "Client ID do seu SPN" # Aqui estou adicionando as informações do meu Service Principal que contem a permissão de Global Administrator no EntraID
$env:ARM_TENANT_ID = "O ID do seu Tenant no EntraID"
$env:ARM_SUBSCRIPTION_ID = "ID da sua subscription"
$env:ARM_CLIENT_SECRET = "Secret do seu SPN" # Aqui estou adicionando as informações do meu Service Principal que contem a permissão de Global Administrator no EntraID
```

- Aqui vamos adicionar as informações de Provider do AzureRM. Adicione o conteudo abaixo no arquivo *provider.tf*

```hcl
provider "azurerm" {
  # Configure the Azure Resource Manager provider
  features {} # Configuration options for the provider
}
```

- Aqui vamos adicionar as informaçoes da versão mais recente do Provider AzureRM e AzureAD. Adicione o conteudo abaixo no arquivo *version.tf*

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

> Se quiser consultar uma versão mais recente, pode buscar nos links a seguir.

- [AzureRM Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)
- [AzureAD Provider](https://registry.terraform.io/providers/hashicorp/azuread/latest)
  {: .prompt-tip }

- Agora vamos adicionar o código para criar o Service Principal. Adicione o conteudo abaixo no arquivo *spn.tf*

```hcl
# Obtenha a configuração do client EntraID atual
data "azuread_client_config" "current" {}

# Obtenha o ID da assinatura atual
data "azurerm_subscription" "current" {}

# Define a role com acesso de contribuidor
data "azurerm_role_definition" "owner" {
  name = "Contributor"
}

# Crie um registro de aplicativo do Azure AD
resource "azuread_application" "app" {
  display_name = "service-principal01"
}

# Crie um Service Principal
resource "azuread_service_principal" "app" {
  client_id                    = azuread_application.app.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

# Período de rotação da senha do Service Principal
resource "time_rotating" "rotation_days" {
  rotation_days = 90
}

# Crie uma senha para o Service Principal
resource "azuread_service_principal_password" "app-password" {
  service_principal_id = azuread_service_principal.app.id

  # Atribui quantidade de dias para a senha
  rotate_when_changed = {
    rotation_days = time_rotating.rotation_days.rotation_days
  }
}

# Exibe o ID do Service Principal
output "sp" {
  value     = azuread_service_principal.app.id
  sensitive = true
}

# Exibe a senha do Service Principal
output "sp_password" {
  value     = azuread_service_principal_password.app-password.value
  sensitive = true
}

# Exiba o ID do cliente
output "client_id" {
  value     = azuread_service_principal.app.client_id
  sensitive = true
}

# Atribue uma permissão ao Service Principal com escopo da subscription
resource "azurerm_role_assignment" "spn-access-rbac" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = data.azurerm_role_definition.owner.name
  principal_id         = azuread_service_principal.app.object_id
}
```

### 4. Inicializar o Terraform

 Já com todos os arquivos codificados, vamos iniciar o Terraform. No terminal do VSCode, digite o comando abaixo.

```powershell
terraform init
```

![Terraform-Init](/assets/img/Lab02-ServicePrincipal/terraform%20init.png){: .shadow .rounded-10}

O *terraform init* é o primeiro passo para configurar um projeto no Terraform. Ele faz uma série de coisas essenciais:

- Prepara o Diretório de Trabalho: Inicializa um novo diretório de trabalho ou reconfigura um existente. Esse diretório contém os arquivos de configuração do Terraform.

- Instala Plugins de Provedor: Baixa e instala os plugins de provedor que são especificados nos arquivos de configuração. Os provedores são responsáveis por interagir com os serviços da nuvem ou outras APIs.

- Inicializa o Backend: Configura o backend que o Terraform utilizará para armazenar o estado da infraestrutura. O estado é um arquivo que mantém o mapeamento das configurações do Terraform com os recursos reais.

É basicamente o comando que prepara tudo para que você possa criar, alterar e destruir infraestrutura com o Terraform. 😊

### 5. Validar se a configuração está Correta

- Nesta etapa vamos executar o *terraform validate* para verificar se os arquivos de configuração criados estão corretos em termos de sintaxe e lógica. Ele não faz alterações nos recursos, apenas valida a configuração. É útil para identificar erros antes de executar o plano *terraform plan*. 😉

```powershell
terraform validate
```

![Terraform-Validate](/assets/img/Lab02-ServicePrincipal/terraform%20validate.png){: .shadow .rounded-10}

#### 6. Validar a formatação dos Arquivos

- Agora vamos executar o *terraform fmt*. Este comando formata os arquivos de configuração para seguir um estilo de código consistente e legível. Corrige indentação, alinhamento e outros aspectos de formatação conforme as convenções do Terraform. É uma boa prática usar esse comando regularmente para manter a base de código organizada.

```powershell
terraform fmt
```

![Terraform-FMT](/assets/img/Lab02-ServicePrincipal/terraform%20fmt.png){: .shadow .rounded-10}

#### 7. Criar as variáveis de ambiente para ser possivel se conectar na Azure

- Neste passo com o powershell aberto, dentro do VSCode, execute o comando abaixo. Ele vai executar o arquivo *powershell-credencials-azure.ps1*.

```powershell
.\powershell-credencials-azure.ps1
```

<center> Notem na figura que eu validei se as variáveis foram adicionadas corretamente </center>
![Set-Azure-Variables](/assets/img/Lab02-ServicePrincipal/SetVariaveisAzure.png){: .shadow .rounded-10}

#### 8. Criar plano de Execução

- Seguido todos esses passos, agora vamos criar um plano, execute o comando *terraform plan -out meu_spn.out*. Ele cria um plano de execução e armazena em um arquivo. O arquivo meu_spn.tfplan é criado para revisar o que será feito sem aplicar as mudanças.

```powershell
terraform plan -out meu_spn.out
```

![Terraform-Plan](/assets/img/Lab02-ServicePrincipal/terraform%20plan.png){: .shadow .rounded-10}

> Na figura acima, estou apresentando somente a quantidade de recursos que serão criados. Isso é necessário porque, ao executar o terraform plan, algumas informações sensíveis, como o ID da subscription onde os recursos serão criados, são exibidas. Para proteger a segurança dos dados e evitar exposição desnecessária dessas informações, optei por mostrar apenas a quantidade de recursos.
{: .prompt-danger }

#### 8. Fazer o deploy dos Recursos

- Agora, com o plano já executado, já sabemos quais recursos serão criados. Vamos executar o *terraform apply meu_spn.out*.
  - Esse comando aplica as mudanças especificadas no arquivo de plano gerado pelo comando *terraform plan*.

```powershell
terraform apply meu_spn.out
```

![Terraform-Apply](/assets/img/Lab02-ServicePrincipal/terraform%20apply.png){: .shadow .rounded-10}

#### 9. Validar as informações no Output

- Voçê pode executar o comando *terraform output*. Ele é utilizado para exibir os valores das variáveis de saída definidas no seu arquivo de configuração do Terraform. Essas variáveis de saída permitem que você acesse e use os valores gerados pela execução do plano de Terraform, como endereços IP, IDs de recursos, URLs e outras informações importantes.

```powershell
terraform output
```

![Terraform-Output](/assets/img/Lab02-ServicePrincipal/terraform%20output.png){: .shadow .rounded-10}

#### 10. Listar recursos criados pelo Terraform

- Vamos executar o comando *terraform state list*. Ele é utilizado para listar todos os recursos gerenciados pelo estado do Terraform.
  - Este comando exibe uma lista de recursos que foram criados, atualizados ou destruídos pelo Terraform e que estão sendo rastreados no arquivo tfstate.

```powershell
terraform state list
```

![Terraform-State-List](/assets/img/Lab02-ServicePrincipal/terraform%20state%20list.png){: .shadow .rounded-10}

#### 11. Validar o Service Principal criado no Portal Azure

- Nas imagens a seguir podemos validar que o Service Principal foi criado com sucesso no Portal Azure.

![SPN-Overview1](/assets/img/Lab02-ServicePrincipal/Validar%20spn%20criado%20no%20Portal.png){: .shadow .rounded-10}
![SPN-Overview2](/assets/img/Lab02-ServicePrincipal/Validar%20spn%20criado%20no%20Portal2.png){: .shadow .rounded-10}

#### 12. Remover recursos criados com Terraform Destroy

- Agora que nós criamos o service principal, vamos fazer a remoção dele. O comando *terraform destroy* é utilizado para destruir todos os recursos gerenciados pelo Terraform em sua configuração. Isso significa que ele apagará todos os recursos da infraestrutura que foram criados ou gerenciados pelo Terraform.

> Esse comando é útil quando você deseja desfazer todas as mudanças aplicadas ou quando precisa limpar o ambiente.
{: .prompt-tip }

![Terraform-Destroy](/assets/img/Lab02-ServicePrincipal/terraform%20destroy.png){: .shadow .rounded-10}
![Terraform-Destroy2](/assets/img/Lab02-ServicePrincipal/terraform%20destroy2.png){: .shadow .rounded-10}

> É importante lembrar que o comando terraform destroy apaga todos os recursos gerenciados pelo Terraform, então use-o com cautela, especialmente em ambientes de produção. Sempre revise o plano de destruição antes de confirmar para garantir que você não está apagando algo por engano.
{: .prompt-danger }

#### 13. Segurança e Boas Práticas

**Armazenamento Seguro de Credenciais**: É recomendável usar o "*Azure Key Vault*" para armazenar informações sensíveis, como IDs de cliente, segredos e certificados. Para integrá-lo ao Terraform, use a <a href="https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/key_vault_secret" target="_blank">provider oficial do Azure</a>. Isso garante que as credenciais sejam acessadas de forma segura e centralizada.

**Exemplo:**

```hcl
data "azurerm_key_vault_secret" "example" {
  name         = "service-principal-secret"
  key_vault_id = azurerm_key_vault.example.id
}
```

**Rotação de Secrets**: Configure políticas de rotação periódica de segredos no Azure Key Vault ou automatize esse processo para minimizar riscos de segurança.

### Conclusão

Utilizar o Service Principal no Azure não apenas automatiza processos, mas também fortalece a segurança ao garantir que as permissões sejam estritamente necessárias. Com o Terraform, podemos criar e gerenciar essa identidade de forma eficiente, mantendo práticas de governança e controle de acesso. Agora, é hora de aplicar esses conceitos na sua infraestrutura, aprimorando sua automação e segurança.

### Resumo

Neste artigo, exploramos o processo de criação de um Service Principal no Azure utilizando o Terraform. Abordamos desde os pré-requisitos necessários, como uma conta ativa no Azure e a instalação do Terraform, até a configuração das variáveis de ambiente no Windows. Passo a passo, demonstramos como preparar o ambiente de trabalho, criar a estrutura de arquivos no VSCode e definir as variáveis de ambiente essenciais para o funcionamento adequado do Terraform. Essas etapas são fundamentais para garantir uma automação eficiente e segura na gestão de recursos no Azure.

### Próximos Passos

Para aprofundar seu conhecimento e expandir as possibilidades de automação com Terraform e Azure, considere os seguintes passos:

- **<a href="https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash" target="_blank">Autenticação do Terraform no Azure</a>**: Aprenda diferentes métodos de autenticação do Terraform no Azure, incluindo o uso de Service Principals e identidades gerenciadas.

- **<a href="https://learn.microsoft.com/en-us/azure/databricks/dev-tools/terraform/service-principals" target="_blank">Provisionamento de Service Principals com Terraform</a>**: Explore como o Terraform pode ser utilizado para provisionar Service Principals, facilitando cenários de automação no Azure Databricks.

- **<a href="https://learn.microsoft.com/en-us/answers/questions/1250584/what-permissions-does-my-service-principal-need-to" target="_blank">Gerenciamento de Permissões de Service Principals</a>**: Entenda as permissões necessárias para que um Service Principal possa interagir com recursos como o Azure Key Vault, garantindo segurança e conformidade.

- **<a href="https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform?pivots=development-environment-azure-cli" target="_blank">Integração do Terraform com o Azure Kubernetes Service (AKS)</a>**: Descubra como implantar clusters do AKS usando o Terraform, ampliando suas habilidades em orquestração de contêineres no Azure.

Até a próxima!! 😉

![resource-group](/assets/img/02/cloudinsights3.png){: .shadow .rounded-10}

#CloudInsights #Azure #Tech #Cloud #Security #Network #Terraform #EntraID

---

[![Build and Deploy](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml/badge.svg)](https://github.com/williamcrcosta/williamcosta.github.io/actions/workflows/pages-deploy.yml)

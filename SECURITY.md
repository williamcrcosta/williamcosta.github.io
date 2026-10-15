# Política de Segurança

## Escopo

Este repositório contém um site estático (Jekyll) publicado via GitHub Pages. Não processa dados de usuários nem expõe serviços — os riscos principais são dependências desatualizadas, supply chain em GitHub Actions e conteúdo com orientações técnicas incorretas.

## Reportar uma vulnerabilidade

Se você encontrar um problema de segurança — por exemplo, uma dependência vulnerável, um exemplo de tutorial com prática insegura ou conteúdo que exponha credenciais:

- **Não abra uma issue pública** com detalhes exploráveis.
- Reporte pela aba **Security → Report a vulnerability** (GitHub Private Vulnerability Reporting), ou
- Contate pelo LinkedIn: [williamcrpc](https://www.linkedin.com/in/williamcrpc/)

Você receberá uma resposta assim que possível. Correções são tratadas com prioridade sobre novos conteúdos.

## Boas práticas adotadas

- Dependabot habilitado para gems (`bundler`) e GitHub Actions.
- Branches `main` e `dev-qa` protegidas: alterações via PR com CI.
- Workflows com permissões mínimas (`contents: read`) e actions em versões Node 24.
- Nenhum segredo ou credencial deve ser commitado — exemplos usam placeholders.

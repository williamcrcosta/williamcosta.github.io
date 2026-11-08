# Backlog Técnico

Melhorias de infraestrutura, segurança e processo do blog. Não são posts.

## Preview de PRs para dev-qa

**Status:** Planejado
**Prioridade:** Média
**Origem:** Análise de melhorias (pós-auditoria)

### Objetivo

Ter uma URL de preview para testar o site antes de mergear PRs na `dev-qa` — hoje só é possível baixar o artifact do CI ou testar localmente.

### Opções avaliadas

| Opção | Prós | Contras |
| --- | --- | --- |
| **Cloudflare Pages** | Preview automático por PR, Jekyll nativo, grátis, sem workflow extra | Requer conta/conta Cloudflare |
| **Netlify** | Preview por PR, bom free tier | Requer `netlify.toml` ou config no painel |
| **Vercel** | Preview por PR | Free tier voltado a Node |
| **GitHub Actions artifact** | Já existe, zero dependência externa | Manual (baixar zip), sem URL pública |
| **Segundo repo GitHub Pages** | Só GitHub | Repo extra, `baseurl` diferente pode quebrar links |

### Recomendação

Cloudflare Pages conectado ao repo:

1. Criar projeto Pages apontando para o repositório.
2. Build command: `bundle exec jekyll build`; output: `_site`; Ruby 3.3.
3. Preview habilitado para branches ≠ `main` — cada PR ganha URL `*.pages.dev`.
4. Opcional: comentário automático no PR com a URL de preview.

## Demais itens da análise (não iniciados)

- [x] Workflow agendado semanal para checar links externos (link rot) — `link-check.yml`
- [ ] Pin de GitHub Actions por SHA (supply chain)
- [x] `html-proofer ~> 5.2` e `jekyll 4.4` via Dependabot
- [x] Migração para Chirpy 7 (v7.6.0; PRs #116, #118 — incluiu correção do entrypoint scss `main.bundle` para bundlar o Bootstrap em produção)
- [x] Remover ~8,4 MB de imagens órfãs (`Bastion-azcli/new/`, `Bicep/`, `Lab0X-EventHUB-Splunk`)
- [x] Remover GIFs/fonte pesada excluídos do build (`*.gif`, `profile.png`)
- [ ] Converter PNGs >1 MB referenciadas para WebP
- [ ] Configurar `google_site_verification` (Search Console)
- [x] Limpar `_data/assets/self_host.yml` dormente

## Lição aprendida (migração Chirpy 7)

O ambiente de desenvolvimento pode mascarar bugs de produção. Exemplo real: o Bootstrap vem da CDN fora de produção, então o override de scss desatualizado só quebrou o site publicado. Sempre validar com `JEKYLL_ENV=production bundle exec jekyll build` antes de mudanças de tema/assets. Preview por PR (item acima) pegaria esse tipo de bug automaticamente.

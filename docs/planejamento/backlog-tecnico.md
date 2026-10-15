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
- [ ] Avaliar migração para Chirpy 7 (mudança maior; Jekyll 4.4 já funciona com o 6.5.5)
- [ ] Remover ~8,4 MB de imagens órfãs (`Bastion-azcli/new/`, `Bicep/`, `Lab0X-EventHUB-Splunk`)
- [ ] Remover GIFs/fonte pesada excluídos do build (`*.gif`, `profile.png`)
- [ ] Converter PNGs >1 MB referenciadas para WebP
- [ ] Configurar `google_site_verification` (Search Console)
- [ ] Limpar `_data/assets/self_host.yml` dormente

# MDBook Documentation — Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create an MDBook documentation site that replaces the monolithic README with a navigable book, deployed to GitHub Pages.

**Architecture:** MDBook project in `docs/` with content migrated from README.md, CONTRIBUTING.md, and SECURITY.md. GitHub Actions workflow builds and deploys on push to main. README.md shortened to overview + links.

**Tech Stack:** MDBook, GitHub Actions (`peaceiris/actions-gh-pages`), Markdown

---

### Task 1: MDBook scaffold

**Files:**
- Create: `docs/book.toml`
- Create: `docs/src/SUMMARY.md`

**Step 1: Create `docs/book.toml`**

```toml
[book]
title = "TYPO3 Docker Images"
authors = ["dkd Internet Service GmbH"]
language = "en"
multilingual = false
src = "src"

[output.html]
default-theme = "light"
preferred-dark-theme = "navy"
git-repository-url = "https://github.com/dkd-dobberkau/typo3-base"
edit-url-template = "https://github.com/dkd-dobberkau/typo3-base/edit/main/docs/{path}"
```

**Step 2: Create `docs/src/SUMMARY.md`**

```markdown
# Summary

[Introduction](introduction.md)

# User Guide

- [Getting Started](getting-started/README.md)
  - [Quick Start](getting-started/quick-start.md)
  - [Base Image](getting-started/base-image.md)
  - [Demo Image](getting-started/demo-image.md)

- [Guides](guides/README.md)
  - [Production Deployment](guides/production-deploy.md)
  - [Kubernetes](guides/kubernetes.md)
  - [Environment Variables](guides/environment-vars.md)
  - [Core Contribution](guides/core-contribution.md)

# Reference

- [Architecture](reference/architecture.md)
- [PHP Extensions](reference/php-extensions.md)
- [Volumes](reference/volumes.md)
- [Config Mapping](reference/config-mapping.md)

# Development

- [Building](development/building.md)
- [Testing](development/testing.md)
- [Contributing](development/contributing.md)
- [Security](development/security.md)
```

**Step 3: Commit**

```bash
git add docs/book.toml docs/src/SUMMARY.md
git commit -m "docs: add MDBook scaffold with book.toml and SUMMARY"
```

---

### Task 2: Introduction + Getting Started pages

**Files:**
- Create: `docs/src/introduction.md`
- Create: `docs/src/getting-started/README.md`
- Create: `docs/src/getting-started/quick-start.md`
- Create: `docs/src/getting-started/base-image.md`
- Create: `docs/src/getting-started/demo-image.md`

**Step 1: Create `docs/src/introduction.md`**

Migrate from README.md lines 1–9: project overview, badge, multi-arch note, image overview table (base/demo/contrib one-liner each). Keep it short — 15-20 lines.

**Step 2: Create `docs/src/getting-started/README.md`**

Section intro — 2–3 sentences orienting the reader to the three images and when to use which.

**Step 3: Create `docs/src/getting-started/quick-start.md`**

Migrate from README.md lines 73–93: `docker compose -f docker-compose.demo.yml up`, URLs, credentials. Fastest path to a running TYPO3.

**Step 4: Create `docs/src/getting-started/base-image.md`**

Migrate from README.md lines 11–56: nginx vs fpm variants, tags table, Dockerfile usage examples for both variants.

**Step 5: Create `docs/src/getting-started/demo-image.md`**

Migrate from README.md lines 58–93: demo tags table, quick start, credentials, Introduction Package variant (`-intro` tags from PR #23).

**Step 6: Commit**

```bash
git add docs/src/introduction.md docs/src/getting-started/
git commit -m "docs: add introduction and getting-started pages"
```

---

### Task 3: Guides pages

**Files:**
- Create: `docs/src/guides/README.md`
- Create: `docs/src/guides/production-deploy.md`
- Create: `docs/src/guides/kubernetes.md`
- Create: `docs/src/guides/environment-vars.md`
- Create: `docs/src/guides/core-contribution.md`

**Step 1: Create `docs/src/guides/README.md`**

Section intro — overview of available guides.

**Step 2: Create `docs/src/guides/production-deploy.md`**

Content from `docker-compose.prod.yml` (added in PR #23) and `.env.prod.example`. Walk through: copy files, configure `.env`, build project image, start stack, Traefik SSL. Reference the "Relationship to DDEV" table from README.

**Step 3: Create `docs/src/guides/kubernetes.md`**

Placeholder page — FPM variant recommended, link to base-image page, note that Helm chart is planned (from TODO.md). Mark as "Coming Soon".

**Step 4: Create `docs/src/guides/environment-vars.md`**

Migrate from README.md lines 141–231: all env var tables (Database, TYPO3, Mail, Graphics, PHP, Redis). Include the "Extending the Config Mapping" section with the PHP code example.

**Step 5: Create `docs/src/guides/core-contribution.md`**

Migrate from README.md lines 95–139: contrib image, tags, step-by-step setup with git clone + docker compose.

**Step 6: Commit**

```bash
git add docs/src/guides/
git commit -m "docs: add guides (production, k8s, env vars, contrib)"
```

---

### Task 4: Reference pages

**Files:**
- Create: `docs/src/reference/architecture.md`
- Create: `docs/src/reference/php-extensions.md`
- Create: `docs/src/reference/volumes.md`
- Create: `docs/src/reference/config-mapping.md`

**Step 1: Create `docs/src/reference/architecture.md`**

Migrate from README.md lines 234–252: ASCII diagram, variant table. Add detail from CLAUDE.md about build stages, key directories, build variables.

**Step 2: Create `docs/src/reference/php-extensions.md`**

Migrate from README.md lines 268–274: extension list, Composer version, GraphicsMagick.

**Step 3: Create `docs/src/reference/volumes.md`**

Migrate from README.md lines 276–285: mount point table. Add security notes from SECURITY.md lines 43–48.

**Step 4: Create `docs/src/reference/config-mapping.md`**

Expand the "Extending the Config Mapping" section from README.md lines 217–232. Explain the `$configMappings` array pattern, how to add custom mappings, mounting your own `additional.php`.

**Step 5: Commit**

```bash
git add docs/src/reference/
git commit -m "docs: add reference pages (architecture, extensions, volumes, config)"
```

---

### Task 5: Development pages

**Files:**
- Create: `docs/src/development/building.md`
- Create: `docs/src/development/testing.md`
- Create: `docs/src/development/contributing.md`
- Create: `docs/src/development/security.md`

**Step 1: Create `docs/src/development/building.md`**

Migrate from CONTRIBUTING.md lines 17–36: all `make` targets with descriptions. Add the build variables table. Include `make matrix` for full builds.

**Step 2: Create `docs/src/development/testing.md`**

Migrate from CONTRIBUTING.md lines 38–51: smoke tests, integration tests. Document CI pipeline stages from CONTRIBUTING.md lines 98–106.

**Step 3: Create `docs/src/development/contributing.md`**

Migrate from CONTRIBUTING.md: prerequisites, getting started, project structure tree, submitting changes, PR guidelines.

**Step 4: Create `docs/src/development/security.md`**

Migrate full SECURITY.md content: supported versions, reporting, security practices (credentials, container security, network, volumes, updates, database).

**Step 5: Commit**

```bash
git add docs/src/development/
git commit -m "docs: add development pages (building, testing, contributing, security)"
```

---

### Task 6: GitHub Actions docs workflow

**Files:**
- Create: `.github/workflows/docs.yml`

**Step 1: Create the workflow**

```yaml
name: Deploy Documentation

on:
  push:
    branches: [main]
    paths:
      - 'docs/**'
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: pages
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Install mdbook
        run: |
          MDBOOK_VERSION="0.4.43"
          curl -sSL "https://github.com/rust-lang/mdBook/releases/download/v${MDBOOK_VERSION}/mdbook-v${MDBOOK_VERSION}-x86_64-unknown-linux-gnu.tar.gz" \
            | tar -xz -C /usr/local/bin

      - name: Build book
        run: mdbook build docs

      - name: Upload Pages artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: docs/book

  deploy:
    needs: build
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

**Step 2: Commit**

```bash
git add .github/workflows/docs.yml
git commit -m "ci: add GitHub Actions workflow for MDBook deployment"
```

---

### Task 7: Shorten README + update cross-references

**Files:**
- Modify: `README.md`
- Modify: `CONTRIBUTING.md`

**Step 1: Shorten README.md**

Keep: badge, one-paragraph overview, images overview (3 images, 1-liner each), quick start (`docker compose up`), architecture ASCII diagram, "Building Locally" with `make build-all` / `make test`, license.

Replace detailed sections (env vars, volumes, extensions, Dockerfile examples, contrib setup) with links like:
`See the [full documentation](https://dkd-dobberkau.github.io/typo3-base/) for detailed guides.`

Target: ~100 lines (down from ~329).

**Step 2: Update CONTRIBUTING.md**

Replace body with a short redirect:

```markdown
# Contributing

See the [Contributing Guide](https://dkd-dobberkau.github.io/typo3-base/development/contributing.html) in the documentation.

For a quick start:

\`\`\`bash
git clone https://github.com/dkd-dobberkau/typo3-base.git
cd typo3-base
make build-all
make test
\`\`\`
```

**Step 3: Commit**

```bash
git add README.md CONTRIBUTING.md
git commit -m "docs: shorten README, link to MDBook for details"
```

---

### Task 8: Verify local build

**Step 1: Install mdbook if needed**

Run: `which mdbook || brew install mdbook`

**Step 2: Build the book**

Run: `mdbook build docs`
Expected: Clean build, no warnings, output in `docs/book/`

**Step 3: Serve and verify**

Run: `mdbook serve docs --open`
Expected: Book opens in browser, all links work, content renders correctly.

**Step 4: Add `docs/book/` to `.gitignore`**

Append `docs/book/` to `.gitignore` so build output isn't committed.

**Step 5: Commit**

```bash
git add .gitignore
git commit -m "chore: add docs/book/ to .gitignore"
```

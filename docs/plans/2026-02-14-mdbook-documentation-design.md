# Design: MDBook Documentation

**Date:** 2026-02-14
**Status:** Approved

## Goal

Replace the monolithic README with a navigable MDBook documentation site. The README stays as a compact reference linking to the book for details.

## Audience

- **TYPO3 developers** deploying projects with the base images
- **Maintainers/contributors** working on the image project itself

## Language

English (matching the codebase and README).

## Book Structure

```
docs/
├── book.toml
└── src/
    ├── SUMMARY.md
    ├── introduction.md
    ├── getting-started/
    │   ├── quick-start.md
    │   ├── base-image.md
    │   └── demo-image.md
    ├── guides/
    │   ├── production-deploy.md
    │   ├── kubernetes.md
    │   ├── environment-vars.md
    │   └── core-contribution.md
    ├── reference/
    │   ├── architecture.md
    │   ├── php-extensions.md
    │   ├── volumes.md
    │   └── config-mapping.md
    └── development/
        ├── building.md
        ├── testing.md
        └── contributing.md
```

## Deployment

- Local: `mdbook build` / `mdbook serve`
- CI: GitHub Actions workflow `.github/workflows/docs.yml` deploys to GitHub Pages on push to `main` when `docs/` changes

## Changes to Existing Files

- **README.md**: Shortened to overview + quick start + links to the book
- **CONTRIBUTING.md**: Content migrates into `docs/src/development/contributing.md`, file becomes a redirect

## Approach

Single initial commit with full structure. Content migrated from existing README, CONTRIBUTING.md, and SECURITY.md.

# Design: dkd/imgproxy TYPO3 Extension

**Date:** 2026-02-17
**Status:** Approved

## Problem

TYPO3 base Docker images include GraphicsMagick for image processing. In Kubernetes HA setups this causes:

- Larger container images (~50-80MB extra with dependencies)
- Increased attack surface (native C libraries with historical CVEs)
- CPU-intensive image processing competes with PHP request handling
- Each pod needs enough CPU/memory headroom for processing spikes

## Solution

A TYPO3 extension (`dkd/imgproxy`) that delegates image processing to an external [imgproxy](https://imgproxy.net/) service via the TYPO3 FAL `ProcessorInterface`. Combined with a "slim" Docker base image variant (without GraphicsMagick), this enables lightweight PHP containers in K8s where imgproxy runs as a separate service or sidecar.

## Scope

- **TYPO3 versions:** 13, 14
- **Backend:** imgproxy only (Go + libvips)
- **Architecture:** Custom `ProcessorInterface` registered before `LocalImageProcessor`
- **Package:** `dkd/imgproxy` (Composer), `EXT:imgproxy` (TYPO3)
- **Location:** Separate repository (`typo3-imgproxy`)

## Architecture

```
TYPO3 FAL Processing Pipeline
  FileProcessingService
       │
       ▼
  ProcessorRegistry
       │
       ├─► ImgproxyProcessor (priority: before LocalImageProcessor)
       │     canProcessTask() → checks imgproxy availability
       │     processTask()   → HTTP request to imgproxy
       │
       └─► LocalImageProcessor (fallback)

┌──────────────┐    HTTP     ┌──────────────┐
│ PHP Container │ ─────────► │   imgproxy   │
│ (slim, no GM) │            │  (Go/libvips)│
└──────────────┘             └──────────────┘
```

## Class Structure

```
Classes/
├── Resource/
│   └── Processing/
│       └── ImgproxyProcessor.php      # ProcessorInterface implementation
├── Service/
│   └── ImgproxyService.php            # HTTP client for imgproxy API
└── Configuration/
    └── ImgproxyConfiguration.php      # Config DTO
```

## Configuration

Extension settings (Admin Tools > Settings) and environment variables:

| Setting | Env Var | Default | Description |
|---------|---------|---------|-------------|
| `imgproxyUrl` | `IMGPROXY_URL` | `http://imgproxy:8080` | imgproxy service URL |
| `imgproxyKey` | `IMGPROXY_KEY` | `` | HMAC key for URL signing (hex) |
| `imgproxySalt` | `IMGPROXY_SALT` | `` | HMAC salt for URL signing (hex) |
| `timeout` | - | `10` | HTTP timeout in seconds |
| `fallbackToLocal` | - | `true` | Fall back to LocalImageProcessor on error |
| `sourceUrlPrefix` | `IMGPROXY_SOURCE_PREFIX` | `local:///` | How imgproxy accesses source files |

## Processing Flow

1. `canProcessTask()`: Check if task type is supported and imgproxy is configured
2. Extract source file and processing config (width, height, crop) from task
3. Translate TYPO3 processing parameters to imgproxy URL options
4. Sign URL with HMAC (key/salt)
5. HTTP GET to imgproxy
6. Save response as ProcessedFile
7. On error: log, mark task unprocessed → LocalImageProcessor takes over

## imgproxy URL Mapping

| TYPO3 Parameter | imgproxy Option |
|----------------|-----------------|
| `width` / `height` | `rs:fit:{w}:{h}` |
| `maxWidth` / `maxHeight` | `rs:fit:{w}:{h}` |
| `minWidth` / `minHeight` | `rs:fill:{w}:{h}` |
| `crop` (area) | `crop:{w}:{h}/{x}/{y}` |
| Output format | `f:{format}` (auto WebP/AVIF) |

## Source File Access

imgproxy needs access to original files. Configurable via `sourceUrlPrefix`:

| Setup | Prefix | Description |
|-------|--------|-------------|
| Shared Volume (K8s PVC) | `local:///` | imgproxy mounts same volume |
| HTTP | `http://typo3-web/` | imgproxy fetches via HTTP |
| S3 | `s3://bucket/` | Both access S3 |

## Existing Alternatives

- `somehow-digital/typo3-media-processing`: 16+ providers, heavier, SaaS focus
- `christophlehmann/imgproxy`: URL-rewriting approach, no local storage
- `stefanfroemken/typo3-image-proxy`: Similar scope, different API

Our extension focuses on: minimal code, `ProcessorInterface` approach, Docker/K8s integration, local fallback.

## Docker Integration (Future)

In `typo3-base`, a new slim image variant without GraphicsMagick:
- `:{PHP_VERSION}-nginx-slim` / `:{PHP_VERSION}-fpm-slim`
- Paired with imgproxy sidecar in K8s deployments
- Documented with example Kubernetes manifests

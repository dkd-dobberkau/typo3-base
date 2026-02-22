# Core Contribution

`dkd-dobberkau/contrib` is a ready-to-run environment for contributing to the TYPO3 Core. It uses the FPM base image with a host-side Git checkout of the TYPO3 mono repository, set up as a Composer-based project.

## Available Tags

| Tag | PHP | Description |
|-----|-----|-------------|
| `8.2` | 8.2 | Minimum PHP for TYPO3 Core |
| `8.3` | 8.3 | |
| `8.4` | 8.4 | Latest PHP |
| `latest` | 8.2 | Alias for `8.2` |

## Setup

### 1. Create a Working Directory and Clone TYPO3 Core

```bash
mkdir ~/TYPO3-Contrib && cd ~/TYPO3-Contrib
git clone --branch=main ssh://YOUR_USERNAME@review.typo3.org:29418/Packages/TYPO3.CMS.git typo3core
```

Replace `YOUR_USERNAME` with your [my.typo3.org](https://my.typo3.org) username.

### 2. Download the Compose File

```bash
curl -O https://raw.githubusercontent.com/dkd-dobberkau/typo3-base/main/docker-compose.contrib.yml
```

### 3. Start the Environment

```bash
docker compose -f docker-compose.contrib.yml up --build
```

| Service | URL |
|---------|-----|
| Frontend | [http://localhost:28080](http://localhost:28080) |
| Backend | [http://localhost:28080/typo3](http://localhost:28080/typo3) |
| Mailpit | [http://localhost:28025](http://localhost:28025) |

Credentials: `contrib` / `Th4nx4H3lp1ng`

### 4. Install Additional Packages

Enter the web container to require additional packages:

```bash
docker compose -f docker-compose.contrib.yml exec web composer require "georgringer/news:*"
```

## How It Works

The contrib image mounts your local TYPO3 Core checkout into the container. Changes you make on the host are immediately reflected inside the container. The environment includes:

- PHP-FPM + Nginx
- MariaDB
- Redis cache backend
- Mailpit for mail testing
- Composer (pre-installed in the base image)

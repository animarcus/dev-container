# Dev container for easier development

## Table of Contents

- [Dev container for easier development](#dev-container-for-easier-development)
  - [Table of Contents](#table-of-contents)
  - [What this project is](#what-this-project-is)
  - [Setup and Installation](#setup-and-installation)
    - [1. Configure environment variables](#1-configure-environment-variables)
    - [2. Add your SSH key](#2-add-your-ssh-key)
    - [3. Build and run containers](#3-build-and-run-containers)
    - [4. Connect to your container](#4-connect-to-your-container)
  - [Using Different Environments](#using-different-environments)
  - [CLI Usage](#cli-usage)
  - [Config](#config)
  - [Customizing Your Environment](#customizing-your-environment)
    - [Adding Custom Volume Mounts](#adding-custom-volume-mounts)
    - [File Permissions](#file-permissions)

## What this project is

This project serves as a dev container management with different development environments.

I started working on this repo because I wanted a portable dev environment I could set up anywhere, provided I have Docker installed. This allows me then to connect to the container through port `2222` and use an IDE which accesses the system remotely, allowing for a native-like experience inside a container.

I am using the Devcontainers offered by Microsoft, but I am augmenting them with my own needs and usages.

My first test of practical usage of this project is for a course I'm following where we have to program in C. They are recommending against using an OS other than Linux, since the project will most likely be OS dependent.

You can run the dev-container container from the `docker-compose.yml`, but the CLI script is there to make it go a bit faster.

I set up my base development environment that I want anyway, and then I add onto them for any other projects I work on. Hence the `environments/c/` folder which uses the base image and then installs some more programs that are needed. There is a template to show how to extend the setup with your own Dockerfile.

The `/workspace` folder inside the container is mounted to the same folder inside this repo. It is ignored by this current repo so that you can do whatever you want inside of it. Make sure to create your own `.env` file following the `env-example`, this is crucial for user permissions of the files created from within the container.

## Setup and Installation

### 1. Configure environment variables

Create your `.env` file from the template:

```bash
cp ./env-example ./.env
```

Then edit the `.env` file to fill in the required values:

```bash
# Run the 'id' command to get your user and group IDs
id

# Example output: uid=501(username) gid=20(groupname) ...
# Open .env in your editor and add these values:
#   PUID=501
#   PGID=20
```

⚠️ **IMPORTANT**: The build will fail if you don't set PUID and PGID values. This is intentional to ensure proper file permissions between your host system and the container.

The other environment variables (DEV_USER, TZ, SSH_PORT, DEV_ENV) are pre-configured in the env-example with sensible defaults, but you can customize them as needed.

### 2. Add your SSH key

```bash
# Create the SSH directory if needed
mkdir -p ./configs/common/ssh

# Copy your SSH public key to authorized_keys
cp ~/.ssh/id_rsa.pub ./configs/common/ssh/authorized_keys
```

### 3. Build and run containers

```bash
# Build the base container (provides foundation for all environments)
docker compose build base

# Build the development container 
# (Uses DEV_ENV from .env to determine which environment to build)
docker compose build dev-container

# Start only the dev container (base is just for building)
docker compose up -d dev-container
```

### 4. Connect to your container

```bash
# Connect via SSH (replace vscode with your DEV_USER value if changed)
ssh -p 2222 vscode@localhost
```

Or add this to your `~/.ssh/config` for easier connection:

```config
Host dev-containers
    Port 2222
    User vscode          # Change this to match your DEV_USER in .env
    HostName localhost
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
```

Then connect with `ssh dev-containers`.

## Using Different Environments

The repository supports multiple development environments:

```bash
# For C development (edit DEV_ENV="c" in .env)
docker compose up -d dev-container

# For base environment (edit DEV_ENV="base" in .env)
docker compose up -d dev-container

# Alternative: Override environment without editing .env
DEV_ENV=c docker compose up -d dev-container
```

## CLI Usage

```bash
# Full rebuild from scratch (like your working command):
./cli.sh start c --rebuild

# Quick start without rebuild:
./cli.sh start c

# Rebuild only environment container:
./cli.sh start c --rebuild-env

# Complete purge and rebuild:
./cli.sh start c --purge
```

## Config

The `configs/common` directory is mounted to `/etc/dev/common` in the container, which allows you then to copy over the files you need at their right places during build time.
As for the env-specific configurations, you should manually copy them in the Dockerfile, since the context for the containers in the `docker-compose.yml` is the root of the repo.

## Customizing Your Environment

### Adding Custom Volume Mounts

If you need to mount additional directories (like local file systems or network shares), use a `docker-compose.override.yml` file:

1. Create the file in the project root (next to docker-compose.yml):

```yaml
# docker-compose.override.yml
services:
  dev-container:
    volumes:
      # Add your custom mounts here
      - /path/on/host:/home/${DEV_USER}/custom-dir:rw,delegated
      - /another/path:/home/${DEV_USER}/another-dir:rw,delegated
```

2. Add this file to `.gitignore` to keep your custom configuration private

This approach keeps your custom settings separate from the main configuration. Docker Compose automatically merges this file with the main `docker-compose.yml` when you run commands.

No additional steps are needed - just create the file and run `docker compose up -d dev-container` as usual.

### File Permissions

By default, the container only changes ownership recursively for critical directories to balance performance and functionality. If you experience permission issues with IDEs like CLion when using Remote SSH, you can enable recursive ownership:

```env
# In your .env file
RECURSIVE_CHOWN=true
```

> [!note] Note that enabling recursive ownership will make container startup slower, especially for large project directories, but it ensures consistent file permissions throughout your workspace.

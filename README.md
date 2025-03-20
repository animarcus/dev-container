# Dev container for easier development

## Using this repo

Make sure to add your public SSH key to `config/common/ssh/authorized_keys` so that the container can recognize you!

```bash
cd /path/to/this/repo/root
cp /path/to/your/.pub/ssh/key ./configs/common/ssh/authorized_keys
```

It might be useful to change your ssh config, so that you can more easily connect to the container
Here is an example of a section of the `~/.ssh/config` file.

```bash
Host dev-containers
    Port 2222
    User marcus
    HostName localhost
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
    SetEnv TERM=xterm-256color
```

Make sure you also have the `.env` file with the right environment variables (necessary for building and running the containers).

```bash
cp ./env-example ./.env
```

Finally, to run the dev-container

```bash
docker compose build base dev-container && \
docker compose up -d dev-container
```

## What this project is

This project serves as a dev container management with different development environments.

I started working on this repo because I wanted a portable dev environment I could set up anywhere, provided I have Docker installed. This allows me then to connect to the container through port `2222` and use an IDE which accesses the system remotely, allowing for a native-like experience inside a container.

I am using the Devcontainers offered by Microsoft, but I am augmenting them with my own needs and usages.

My first test of practical usage of this project is for a course I'm following where we have to program in C. They are recommending against using an OS other than Linux, since the project will most likely be OS dependent.

You can run the dev-container container from the `docker-compose.yml`, but the CLI script is there to make it go a bit faster.

I set up my base development environment that I want anyway, and then I add onto them for any other projects I work on. Hence the `environments/c/` folder which uses the base image and then installs some more programs that are needed. There is a template to show how to extend the setup with your own Dockerfile.

The `/workspace` folder inside the container is mounted to the same folder inside this repo. It is ignored by this current repo so that you can do whatever you want inside of it. Make sure to create your own `.env` file following the `env-example`, this is crucial for user permissions of the files created from within the container.

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

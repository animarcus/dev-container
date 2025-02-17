# Dev container for easier remote development

This repo was originally intended for easier development and management of a homelab running on a Synology NAS.
It's a server I'm taking over, so I need a way to explore the files and configurations that are in a chosen folder.
This also allows me to use tools that I install on the container without worrying about bloating the host, and for testing things out.

## CLI Usage

```bash
# Start with defaults
./scripts/cli.sh start

# Start C environment with rebuild
./scripts/cli.sh start c --rebuild

# Complete reset and rebuild
./scripts/cli.sh start c --purge

# Build base image only
./scripts/cli.sh build --base-only

# Clean stop and restart
./scripts/cli.sh start --clean-stop
```

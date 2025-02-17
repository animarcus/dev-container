# Creating New Development Environments

To create a new environment:

1. Create a new directory under `environments/`
2. Copy this template
3. Modify Dockerfile to add needed tools
4. Document tools and purpose in README.md
5. Add environment-specific configs in `configs/env-specific/<env>`

## Example Dockerfile

```dockerfile
FROM dev-container-base:latest

# Add environment-specific tools
RUN apt-get update && apt-get install -y \
    package1 \
    package2

# Add any environment-specific configuration
COPY configs/env-specific/myenv /etc/dev/env-specific

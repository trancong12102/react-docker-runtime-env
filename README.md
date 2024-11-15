# React + Docker runtime environment variables

This is a simple example of how to use environment variables in a Vite + React project running in a Docker container.

## How does it work?

The `entrypoint.sh` script is executed when the Docker container starts. This script replaces the environment variables in the `*.js` files with the values defined in the `.env.production` file.

This technique also works with next `NEXT_PUBLIC_` variables.

See the [Dockerfile](Dockerfile) and the [entrypoint.sh](entrypoint.sh) for more details.

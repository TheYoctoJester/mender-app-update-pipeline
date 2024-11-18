# mender-app-update-pipeline

## Motivation

[Docker Compose](https://docs.docker.com/compose/) is a popular container orchestration solution which can also be used for edge-style devices. This example project can serve as a template for a DevOps-style deployment of a `docker-compose` based application setup through [Mender](https://mender.io).

## Usage

The example pipeline consists of the following parts:

- [`docker-compose.yml`](./docker-compose.yaml): the Docker Compose-style manifest of containers which you want to deploy. It is based on the [tutorial on application updates](https://docs.mender.io/artifact-creation/create-an-artifact/docker-compose#create-the-mender-artifact) in the Mender documentation, and showcases a simple `traefik`+`whoami` setup.
- [`build_dind.yml`](./.github/workflows/build_dind.yml): the actual pipeline. It can be used as a template, where you adjust the environment variable declarations near the top to your requirements.

Requisites:
- A compatible device to deploy to. The example pipeline uses a Raspberry Pi 4 64bit, running an image built with [this tutorial](https://hub.mender.io/t/using-the-docker-compose-application-update-module-on-yocto/6133)
- a Hosted Mender account, to create a [personal access token (PAT)](https://docs.mender.io/server-integration/using-the-apis#personal-access-tokens) and store it as a [GitHub Actions secret](https://docs.github.com/en/actions/security-for-github-actions/security-guides/using-secrets-in-github-actions). The example expects it under the name `MENDER_SERVER_ACCESS_TOKEN`.

## Implementation details

- workflow: the [`build_dind.yml`](./.github/workflows/build_dind.yml) file sets up an Ubuntu-22.04 based container, and installs the required packages:
  - `docker`
  - `mender-artifact`
  - `app-gen` script
  Additionally, it enables `docker` inside by requesting the service from the host, therefore the name "dind", short for "Docker-in-Docker". This is required for the `app-gen` script, which needs to run docker for obtaining the containers to package.

- triggers: the example has three triggers configured.
  - `workflow_dispatch`: so the workflow can be interactively started through the GitHub Actions Web user interface.
  - `push`: the workflow runs to build the artifact upon each push to the `main` branch, so you have a quick feedback loop if the process is still functional
  - `release`: this trigger is limited to the `published` type. The flow is similar to the `push`/`workflow_dispatch` one, but extends it by uploading the artifact to the configured Mender Server and creates a deployment for the devices listed in the `MENDER_DEVICES_LIST` environment variable.
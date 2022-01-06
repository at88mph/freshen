# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.166.1/containers/debian/.devcontainer/base.Dockerfile

# [Choice] Debian version: buster, stretch
FROM elixir:slim

RUN apt-get update \
    && apt-get install -y git inotify-tools \
    && apt-get clean \
    && rm -rf /var/apt/lists/*

RUN mix local.hex --force

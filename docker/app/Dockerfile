# syntax=docker/dockerfile:experimental

# This Docker container achieves a few things needed for a successful GOB build:
# Debian environment for easy package installation and testing;
# installation of a non-root user for RoR dependencies;
# an easy-to-access location for the Docker host to locally mount and build our files.

FROM ubuntu:latest

ENV DISABLE_SPRING=1

# ARGS can be overwritten in docker run or docker-compose
ARG RUBY_VER=3.2.1
ARG RAILS_VERSION=6.1.4.6
ARG VIEW_COMPONENT_VERSION=2.6.6

# many of these env vars will be overwritten by docker/solr/solr.in.sh config if cloud-secure.sh is run
ARG SOLR_HOST=localhost
ARG SOLR_PORT=8983
ARG SOLR_JETTY_HOST=0.0.0.0
ARG SOLR_VERSION=9.1.1
ARG SOLR_URL="http://${SOLR_HOST}:${SOLR_PORT}/solr/blacklight-core/"
ARG ZK_HOST=zoo1:2181

# user and perm args
# NOTE: host user perms are injected in start-me-up.sh
ARG USER=gob
ARG PASS=gobb13
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# project DRY dirs
ENV PROJECT_DIR="/geoblacklight"
ENV APP_DIR="${PROJECT_DIR}/app"
ENV SOLR_DIR="${PROJECT_DIR}/solr"
ENV USER_HOME="/home/${USER}"

# Image install and update packages, and cleaning too!
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -q \
    && apt-get upgrade -qy

RUN apt-get install -qy \
    bash \
    build-essential \
    ca-certificates \
    curl \
    expect \
    git \
    gnupg2 \
    lsof \
    openssl \
    nodejs \
    npm \
    sqlite3 \
    sudo \
    vim \
    tzdata

# install node stuff
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -q
RUN apt-get install -qy \
    yarn

# clean up system deps
RUN apt-get autoremove -y \
    && apt-get --fix-broken install \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# create a newer, shinier sleeve
RUN groupadd --gid ${USER_GID} ${USER} \
    && useradd -p ${PASS} --uid ${USER_UID} --gid ${USER_GID} -m ${USER} \
    && echo ${USER} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USER} \
    && chmod 0440 /etc/sudoers.d/${USER}

RUN mkdir ${PROJECT_DIR} \
    && chown -R ${USER}:${USER} /geoblacklight

RUN echo "source ~/.rvm/scripts/rvm" >> "${USER_HOME}/.bashrc" \
    && echo 'gem: --no-document' >> "${USER_HOME}/.gemrc"

USER gob
EXPOSE 3000
EXPOSE 8983
WORKDIR "${USER_HOME}/docker"

RUN gpg2 --keyserver keyserver.ubuntu.com --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
RUN curl -sSL https://get.rvm.io | bash -s stable
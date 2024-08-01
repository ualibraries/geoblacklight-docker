#!/bin/bash


source .env

cd docker

docker build --rm=true -t ual-goblight:latest \
    --build-arg RUBY_VERSION=${RUBY_VERSION} \
    --build-arg RAILS_VERSION=${RAILS_VERSION} \
    --build-arg VIEW_COMPONENT_VERSION=${VIEW_COMPONENT_VERSION} \
    --build-arg SOLR_USER=${SOLR_USER} \
    --build-arg SOLR_PASS=${SOLR_PASS} \
    --build-arg USER_GID=${DGID} \
    --build-arg USER_UID=${DUID} \
    --build-arg NODE_MAJOR_VERSION=${NODE_MAJOR_VERSION} \
    -f app/Dockerfile .

docker build --rm=true -t ual-solr:latest \
    --build-arg SOLR_VERSION=${SOLR_VERSION} \
    --build-arg SOLR_USER=${SOLR_USER} \
    --build-arg SOLR_PASS=${SOLR_PASS} \
    -f solr/Dockerfile .

MCollectived Docker image
=========================

[![Docker Pulls](https://img.shields.io/docker/pulls/camptocamp/mcollectived.svg)](https://hub.docker.com/r/camptocamp/mcollectived/)
[![By Camptocamp](https://img.shields.io/badge/by-camptocamp-fb7047.svg)](http://www.camptocamp.com)

## Environment variables

### STOMP_USER

Default: mcollective

### STOMP_PASSWORD

Default: marionette

### MCOLLECTIVE_SERVER_KEY

Server private key

### GITHUB_ORG

Organization to use for SSL keys

### GITHUB_TEAM

Team to use for SSL keys

### GITHUB_USERS

Additional users for SSL keys

### GITHUB_TOKEN

The Github token to use to connect to the Github API. It must allow two actions:

- read:org
- read:public_key


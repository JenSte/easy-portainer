# easy-portainer

A configuration template to get the following up and running within seconds:

* A [Traefik](https://traefik.io/) reverse proxy with [Let's Encrypt](https://letsencrypt.org/) support.
* The [Portainer](https://www.portainer.io/) Docker management tool.
* A self-hosted [Docker registry](https://docs.docker.com/registry/deploying/).
* [Docker Registry UI](https://joxit.dev/docker-registry-ui/) for the self-hosted registry.

## Installation

1. Install [Docker](https://docs.docker.com/install/) and [Docker Compose](https://docs.docker.com/compose/install/).
2. Clone this repository, adjust the settings in the `credentials` file.
3. Change your firewall setting so that TCP port 443 is passed through to the host you are installing this.
4. Run the `start.sh` script to start the containers.
5. As Portainer does not have CLI flags for some settings, its configuration has to be finished by hand:
   * Upon first login (see below on how to access it), one has to choose
     "Local - Manage the local Docker environment", and then "Connect" at the lower left.
   * Under "Settings/Registries" the local registry can be added using the URL `localhost:5000`.

## Usage

* If everything is working properly, the TLS connection to your domain should be using
  a valid (verified by Let's Encrypt) server certificate.
* Portainer is accessible under `https://<your domain>/portainer/`.
* The Traefik dashboard is accessible under `https://<your domain>/dashboard/`.
* The self-hosted container registry is accessed by just using the domain name (no port 5000):
  ```
  docker login <your domain>
  ```
  Images pushed to that registry can then be used from within Portainer by selecting the local registry.
* The user interface for the registry is accessible under `https://<your domain>/registry-ui/`.

## Remarks

* Traefik is configured to not automatically serve the network connections of other containers that are started
  in addition.
* Containers created by this template are hidden in Portainer by default. To make them visible, change
  the value assigned to the `PORTAINER_HIDDEN` variable in `start.sh`.
* Images deleted using the web UI are not actually removed from the registry. To actually delete them,
  a garbage collection has to be run inside the registry. This repository contains systemd service and
  timer units to do this periodically. Installation:
  ```
  cp systemd/* /etc/systemd/system/
  systemctl daemon-reload
  systemctl enable --now easy-portainer-cleanup.timer
  ```
  Note that even when all tags of an image are removed, the image is still listed in the top-level list
  of the UI. See also the corresponding entry in the
  [Docker Registry UI FAQ](https://github.com/Joxit/docker-registry-ui#faq) and the linked issue.
* You should make sure that you keep the Docker containers up-to-date,
  especially as they are connected to the public internet.
  One popular way to do this is to use [Watchtower](https://containrrr.github.io/watchtower/),
  a program that watches for updated images and then recreates your containers.
  By default, the containers started by the `start.sh` script already have the
  `com.centurylinklabs.watchtower.enable` label set, but Watchtower has to be started separately.
  For example, you could create a stack in Portainer using the following YAML:
  ```
  version: "2"

  services:
    watchtower:
      image: containrrr/watchtower
      restart: unless-stopped
      volumes:
        - /var/run/docker.sock:/var/run/docker.sock
      command: --label-enable --cleanup
  ```
  Watchtower will then update the container when new images are available,
  and also delete the old, then unused, images.
* To serve additional containers using the traefik proxy, you have to
  attach them to the network called `traefik`, for example:
  ```
  version: "2"

  services:
    myservice:
      image: ...
    networks:
      - "traefik"
    labels:
      - "traefik.enable=true"
      <additional traefik configuration keys here>

  networks:
    traefik:
      external: true
  ```

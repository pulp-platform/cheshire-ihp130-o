#!/bin/bash
cd docker && make pull
env UID=${UID} GID=${GID} docker-compose run pulp-iguana

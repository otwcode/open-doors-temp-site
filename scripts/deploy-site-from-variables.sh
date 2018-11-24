#!/usr/bin/env bash

ansible-playbook scripts/ansible/deploy-site.yml -i scripts/ansible/hosts --extra-vars "@scripts/variables.yml"

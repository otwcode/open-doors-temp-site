#!/usr/bin/env bash

ansible-playbook scripts/ansible/remove-site.yml -i scripts/ansible/hosts --extra-vars "@scripts/variables.yml"

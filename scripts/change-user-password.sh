#!/usr/bin/env bash

ansible-playbook scripts/ansible/change-user-password.yml -i scripts/ansible/hosts --extra-vars "@scripts/variables.yml"

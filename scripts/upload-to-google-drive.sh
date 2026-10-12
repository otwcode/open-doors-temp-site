#!/usr/bin/env bash

ansible-playbook scripts/ansible/download-file.yaml -i scripts/ansible/hosts --extra-vars "@scripts/variables.yml"
ansible-playbook scripts/ansible/upload-to-google-drive.yaml -i scripts/ansible/hosts --extra-vars "@scripts/variables.yml"

# Open Doors Temp Site
Temporary import sites for semi-automated Open Doors imports.

# Overview
The [Open Doors](http://opendoors.transformativeworks.org/) project is dedicated to preserving at-risk fanworks. Part of 
that work involves importing works into Archive of Our Own from external archives which are being closed down. 

Due to the variety of formats in external websites, some of which are completely incompatible with Archive of Our Own's
importing process, some archives are imported using a semi-automated process involving two technical stages after the
initial Open Doors processes:

1. The metadata and works are extracted from a backup of the old archive and converted into standardised MySQL tables 
(see [Open Doors Code](https://github.com/otwcode/open-doors-code) which houses the scripts used for this stage)
1. The standardised data is hosted in a temporary website accessible to import operators and which allows them to 
perform the import in stages, verifying imported works as they go along. This repository houses the Rails application 
used to create those sites.

# Running it locally
Requirements:
- Ruby 2.2.5 (this will be kept in sync with the version used by the `otwarchive` project)
- MySQL 5.7
- Bundler

See [Rails Getting Started Guide](http://guides.rubyonrails.org/getting_started.html) for instructions on installing and configuring Rails.

Once this is done, you can install dependencies and run the Rails application from the command line:
```bash
$ cd path/to/this/repo
$ bundle install
$ bin/rails server
``` 

In your browser, navigate to http://localhost:3010 to view the temp site.

# Deployment
Before you proceed, you will need to install Ansible (https://www.ansible.com/).
1. Create a file called `hosts` with the following contents:
```
[otw]
[[SERVER_NAME]] ansible_ssh_user=[[SERVER_USER]]
```
Where `SERVER_NAME` and `SERVER_USER` are the server and user provided by Systems. 

1. Make a copy of `variables.yml.example` as `variables.yml` and fill it in with the details 
of the site you're creating.

1. Run 
```bash
$ cd scripts/ansible
$ ansible-playbook deploy-site.yml -i hosts --extra-vars "@variables.yml"
```

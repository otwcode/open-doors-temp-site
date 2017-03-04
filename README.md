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

In your browser, navigate to 

#
The server that hosts the 

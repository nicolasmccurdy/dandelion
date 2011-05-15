dandelion
=========

Install
-------
Ensure that Ruby and RubyGems are installed, then run:

    $ gem install dandelion
    
Alternatively, you can build the gem yourself:

    $ git clone git://github.com/scttnlsn/dandelion.git
    $ cd dandelion
    $ rake install
    
Config
------
Configuration options are specified in a YAML file (Dandelion looks for 
`dandelion.yml` by default). Example:

    # Required
    scheme: sftp
    host: example.com
    username: user
    password: pass
    path: path/to/deployment
    
    # Optional
    exclude:
        - .gitignore
        - dandelion.yml

Schemes
-------
There is support for multiple backend file transfer schemes.  The configuration
must specify one of these schemes and the set of additional parameters required
by the given scheme.

**SFTP**: `scheme: sftp`

Required parameters:
`host`, `username`, `password`, `path`
    
**FTP**: `scheme: ftp`

Required parameters:
`host`, `username`, `password`, `path`
    
**Amazon S3**: `scheme: s3`

Required parameters:
`access_key_id`, `secret_access_key`, `bucket_name`, `path`

Usage
-----
From the root directory of a Git repository, run:

    $ dandelion deploy
    
Or:

    $ dandelion deploy path/to/config.yml
    
This will deploy the local `HEAD` revision to the server specified in the config
file.  Dandelion keeps track of the most recently deployed revision so that only
files which have changed since the last deployment need to be transferred.

For a more complete summary of usage options, run:

    $ dandelion -h
    Usage: dandelion [options] [[command] [options]]
        -v, --version                    Display the current version
        -h, --help                       Display this screen
            --repo=[REPO]                Use the given repository

    Available commands:
        deploy
        status
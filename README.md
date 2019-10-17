# gem package -- godigo

Ruby package with command-line client utilities to start and stop a
session on a machine-gazer [rails project -- machine_time](https://github.com/misasa/machine_time).

# Description

Ruby package with command-line client utilities to start and stop a
session on a machine-gazer [rails project --
machine_time](https://github.com/misasa/machine_time).
The utilities help to keep track of machine status.

This package also offers interface for synchronization of local data files.
Action can be `start`, `stop`, and `sync`.

# Dependency

## [gem package -- machine_time_client](https://github.com/misasa/machine_time_client "follow instruction")

## [gem package -- tepra](https://github.com/misasa/tepra)

## [rsync](https://rsync.samba.org/)

If you call `rsync` on MSYS2, make sure if `ssh` for MSYS2 is available.
Following commands will help to find out what do you call.
    CMD> where rsync
    CMD> where ssh

# Installation

Install the package by yourself as:

    $ gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems/
    $ gem install godigo

# Commands

Commands are summarized as:

| command              | description                          | note                |
|----------------------|--------------------------------------|---------------------|
| godigo-session       | Start and stop machine session       |                     |
| godigo-session-start | Start a machine session              |                     |
| godigo-session-stop  | Stop a machine session               |                     |
| godigo-session-sync  | Sync datasets by machine to remote server |                     |

# Usage

See online document with option `--help`.

# Developer's guide

1. This project is hosted in the Git server (https://github.com/misasa/godigo).

2. Run test.

```
$ cd ~/devel-fudo/gems/godigo
$ bundle exec rspec spec/godigo/commands/session_command_spec.rb --tag show_help:true
```

3. Push to the Git server.

4. Access the Jenkins server (http://devel.misasa.okayama-u.ac.jp/jenkins/job/Godigo/), login,
   and run a job.  This is scheduled and if you are not in hurry, skip
   this and the next step.

5. Update DREAM's homepage to have the newest gem available.

6. Uninstall and install gem module locally by following command.

````
$ sudo gem uninstall godigo
$ sudo gem install godigo
````

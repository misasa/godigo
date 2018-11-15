# gem package -- godigo

Ruby package with command-line client utilities to start and stop a
session on a machine-gazer rails project -- machine_time.  The utilities
keep track of machine status.  This package also offers interface for
synchronization.  Action can be start, stop, and sync.

# Description

Ruby package with command-line client utilities to start and stop a
session on a machine-gazer [rails project --
machine_time](https://github.com/misasa/machine_time).  Keep track of
machine status.  This also offers interface for synchronization.
Action can be `start`, `stop`, and `sync`.

# Dependency

## [gem package -- machine_time_client](https://github.com/misasa/machine_time_client "follow instruction")

# Installation

Add this line to your application's Gemfile:

    gem 'godigo'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem source -a http://dream.misasa.okayama-u.ac.jp/rubygems
    $ gem install godigo

# Commands

Commands are summarized as:

| command              | description                          | note                |
|----------------------|--------------------------------------|---------------------|
| godigo-session       | Start, stop, or sync machine session |                     |
| godigo-session-start | Start a machine session              |                     |
| godigo-session-stop  | Stop a machine session               |                     |
| godigo-session-sync  | Sync a machine session               |                     |

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

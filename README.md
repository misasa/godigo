# godigo

Start or stop machine session

# Dependency

## [machine_time_client](http://devel.misasa.okayama-u.ac.jp/gitlab/gems/machine_time_client/tree/master "follow instruction")

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

| command              | description                                                         | note                |
|----------------------|---------------------------------------------------------------------|---------------------|
| godigo-session       | Start, stop, or sync machine session                                |                     |
| godigo-session-start | Start a machine session                                             |                     |
| godigo-session-stop  | Stop a machine session                                              |                     |
| godigo-session-sync  | Sync a machine session                                              |                     |

# Usage

See online document with option `--help`.

# Developer's guide

1. Run test

    $ cd ~/devel-godigo/gems/godigo
    $ bundle exec rspec spec/godigo/commands/session_command_spec.rb --tag show_help:true

2. Push to the Git server

3. Access to Jenkins server http://devel.misasa.okayama-u.ac.jp/jenkins/job/Godigo/ and run a job.  This is scheduled and if you are not in hurry, skip further steps.

4. Uninstall and install local gem module by

    $ sudo gem uninstall godigo
    $ sudo gem install godigo

# Contributing

1. Fork it ( https://github.com/[my-github-username]/godigo/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

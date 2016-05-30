require 'open3'
require 'godigo/cui'
module Godigo::Commands
  class SessionCommand < Godigo::Cui
	def option_parser
	  opts = OptionParser.new do |opt|
		opt.banner = <<-"EOS".unindent
NAME
  #{program_name} - Keep track of machine status

SYNOPSIS
  #{program_name} action [options...]

DESCRIPTION
  Keep track of machine status.  This also offers interface for
  synchronization.  Action can be `start', `stop', and `sync'.
  Machine and machine-server should be specified in a configuration
  file `~/.godigorc' as inferred later.  Note that for each action,
  dedicated application is prepared to be invoked from MS Windows.

  start
    Start `machin' on machine-server to log status.  To
    invoke #{program_name}-start does the same thing.

  stop
    Stop `machin' on machine-server to log status and issue `sync'.
    To invoke #{program_name}-stop does the same thing.

  sync
    Synchronize local directory to remote directory specified in a
    configuration file.  The action invokes `rsync' as sub-process
    when paramters `src_path' and `dst_path' are found in the
    configuration file.  To invoke #{program_name}-sync does the same
    thing.  Options involved are showno below.
    $ rsync -avh --delete -e ssh ${src_path} ${dst_path}

SETUP FOR SYNC
  (1) On Windows, mount a source directory with proper volume name
      such as "U:/".
  (2) Make sure if rsync in installed somewhere discoverable.  In a
      case of Windows, to use rsync on Cygwin is an option.
  (3) Find out how the directory is spelled.  For a case where
      volumme "U:/" on Windows is the source, the directory is
      referred as "/cygdrive/u/" on Cygwin.  Place it onto :src_path:
      in the configuration file.
  (4) Create a directory in a server with proper permission.  Place
      the ssh-based URL onto :dst_path: in the configuration file.
  (5) Setup ssh key to access to the server without authorization.

EXAMPLE OF CONFIGURATION FILE
  ## machine config
  uri_machine: database.misasa.okayama-u.ac.jp/machine
  machine: JSM-7001F-LV
  ## sync config
  src_path: /cygdrive/u/
  dst_path: falcon@archive.misasa.okayama-u.ac.jp:/backup/JSM-7001F-LV/sync/

SEE ALSO
  http://dream.misasa.okayama-u.ac.jp
  TimeBokan
  rsync

IMPLEMENTATION
  Orochi, version 9
  Copyright (C) 2015-2016 Okayama University
  License GPLv3+: GNU GPL version 3 or later

HISTORY
  October 1, 2015: Documentated by Tak Kunihiro
  February 1, 2016: Revise document by Tak Kunihiro
  April 26, 2016: Documentation updated to be more correct

OPTIONS
EOS
		opt.on("-v", "--[no-]verbose", "Run verbosely") {|v| OPTS[:verbose] = v}
		opt.on("-m", "--message", "Add information on start") {|v| OPTS[:message] = v}
		opt.on("-o", "--open", "Open by web browser") {|v| OPTS[:web] = v}
	  end
	  opts
	end

	def get_machine
	  MachineTimeClient::Machine.instance
	end

	def open_browser
	  machine = get_machine
	  url = "http://database.misasa.okayama-u.ac.jp/machine/machines/#{machine.id}"
	  if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|bccwin/
		system("start #{url}")
	  elsif RUBY_PLATFORM.downcase =~ /cygwin/
		system("cygstart #{url}")
	  elsif RUBY_PLATFORM.downcase =~ /darwin/
		system("open #{url}")
	  else
		raise
	  end
	end

	def print_label(session)
	  if RUBY_PLATFORM.downcase !~ /darwin/
		cmd = "tepra print #{session.global_id},#{session.name}"
		Open3.popen3(cmd) do |stdin, stdout, stderr|
		  err = stderr.read
		  unless err.blank?
		    p err
		  end
		end
		# system("tepra-duplicate")
		# system("perl -S tepra-duplicate")
	  end
	end

	def start_session
	  machine = get_machine
	  if machine.is_running?
		stdout.print "An open session |#{machine.name}| exists.  Do you want to close and start a new session? [Y/n] "
	    answer = (stdin.gets)[0].downcase
		if answer == "y" or answer == "\n"
		  machine.stop
		  machine.start
		else
		  exit
		end
	  else
		machine.start
	  end
	  session = machine.current_session
	  print_label session
	  if OPTS[:message]
		message = argv.shift
		if message
		  session.description = message
		  session.save
		end
	  end
	  stdout.puts session if OPTS[:verbose]

	  if OPTS[:web]
		open_browser
	  end
	end


	def stop_session
	  machine = get_machine
	  if machine.is_running?
		session = machine.current_session
		stdout.puts session if OPTS[:verbose]
		machine.stop
		stdout.puts "Session closed"
		sync_session
	  end
	end

	def config
	  MachineTimeClient.config
	end

   
	def checkpoint
	  _path = get_src_path.clone
      #	  if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|bccwin/
 	  if platform =~ /mswin(?!ce)|mingw|bccwin/ # when Ruby is on Windows-NT (mingw) not on Cygwin
		# _path = _path.gsub(/\/cygdrive\/c\/Users/,"C:/Users")
		# _path = _path.gsub!(/\//,"\\")
		_path.gsub!("/cygdrive/c/Users","C:/Users")
		_path.gsub!("/cygdrive/t","T:")
		_path.gsub!("/cygdrive/u","U:")
		_path.gsub!("/cygdrive/v","V:")
		_path.gsub!("/cygdrive/x","X:")
		_path.gsub!("/cygdrive/y","Y:")
		_path.gsub!("/cygdrive/z","Z:")
 	  end
	  File.join(_path, 'checkpoint.org')
	end

	def get_dst_path
      #    dst_path: falcon@itokawa.misasa.okayama-u.ac.jp:/home/falcon/deleteme.d
	  if config.has_key?(:dst_path)
		_path = config[:dst_path]
	  elsif config.has_key?('dst_path')
		_path = config['dst_path']
	  end
	  unless _path
		raise "Machine configuration file |#{MachineTimeClient.pref_path}| does not have parameter |dst_path|.  Put a line such like |dst_path: falcon@archive.misasa.okayama-u.ac.jp:/backup/mymachine/sync|."
	  end
	  _path
	end

	def get_src_path
      #    src_path: C:/Users/dream/Desktop/deleteme.d
	  if config.has_key?(:src_path)
		_path = config[:src_path]
	  elsif config.has_key?('src_path')
		_path = config['src_path']
	  end
	  unless _path
		raise "Machine configuration file |#{MachineTimeClient.pref_path}| does not have parameter |src_path|.  Put a line such like |src_path: C:/Users/dream/Desktop/deleteme.d"
	  end
	  _path
	end

	def checkpoint_exists?
	  File.exists? checkpoint
	end

	def sync_session
	  dst_path = get_dst_path
	  src_path = get_src_path
	  raise "Could not find checkpoint file in #{checkpoint}." unless checkpoint_exists?
	  stdout.print "Are you sure you want to copy #{src_path} to #{dst_path}? [Y/n] "
	  answer = (stdin.gets)[0].downcase
	  unless answer == "n"
       	cmd = "rsync -avh --delete -e ssh #{src_path} #{dst_path}"
       	#stdout.puts cmd
       	system_execute(cmd)
      end
	end

	def execute
	  subcommand =  argv.shift.downcase unless argv.empty?
	  if subcommand =~ /start/
  		start_session
	  elsif subcommand =~ /stop/
  		stop_session
	  elsif subcommand =~ /sync/
  		sync_session
	  else
		raise "invalid command!"
	  end
	end
  end
end

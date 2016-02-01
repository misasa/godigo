require 'open3'
require 'godigo/cui'
module Godigo::Commands
	class SessionCommand < Godigo::Cui
		def option_parser
			opts = OptionParser.new do |opt|
				opt.banner = <<-"EOS".unindent
					NAME
						#{program_name} - Start or stop machine session

					SYNOPSIS
						#{program_name} action [options]

					DESCRIPTION
						Start or stop machine session.  This also offers backup interface.
						Action can be `start', `stop', and `sync'.  Machine and
						machine-server should be specified in a configuration file as inferred
						later.

						start, stop
						  Start or stop the machin on machine-server to log status

						sync
						  Create backup to remote directory specified in a configuration
						  file.  The action invokes `rsync' as sub-process.

					EXAMPLE OF CONFIGURATION FILE `~/.godigorc'
						## godigo-session start/stop
						machine: 6UHP-70
						uri_machine: database.misasa.okayama-u.ac.jp/machine
                        ## godigo-session sync
						src_path: C:/Users/dream/Desktop/deleteme.d
						dst_path: falcon@itokawa.misasa.okayama-u.ac.jp:/home/falcon/deleteme.d

					SEE ALSO
						http://dream.misasa.okayama-u.ac.jp
						TimeBokan

					IMPLEMENTATION
						Orochi, version 9
						Copyright (C) 2015 Okayama University
						License GPLv3+: GNU GPL version 3 or later

                    HISTORY
						October 1, 2015: Documentated by Tak Kunihiro
						February 1, 2016: Revise document by Tak Kunihiro

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
			_path = get_src_path
		  if RUBY_PLATFORM.downcase =~ /mswin(?!ce)|mingw|bccwin/
		    _path = _path.gsub(/\/cygdrive\/c\/Users/,"C:/Users")
		    _path = _path.gsub!(/\//,"\\")
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

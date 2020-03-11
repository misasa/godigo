require 'spec_helper'
require 'godigo/commands/session_command'

module Godigo::Commands
  describe SessionCommand do
    let(:cui) { SessionCommand.new(args, :stdin => stdin, :stdout => stdout, :stderr => stderr, :program_name => 'godigo-session') }
    let(:args){ [] }
    let(:stdout){ Output.new }
    let(:stderr){ Output.new }
    let(:stdin){ double('stdin').as_null_object }
    describe "show_help", :show_help => true do
      it { 
        puts "-" * 5 + " help start" + "-" * 5
        puts cui.opts 
        puts "-" * 5 + " help end" + "-" * 5
      }
    end

    describe "parse_options" do
      subject { cui.parse_options }

      describe "with -v" do
        let(:args){ ["-v"] }
        it { 
          subject
          expect(cui.options).to include(:verbose => true)
        }
      end
    end

    describe "execute" do   
      subject { cui.execute }
      before do
        cui.parse_options
      end

      describe "with start" do
        let(:args){ [cmd] }
        let(:cmd){ "start" }
        before do
          allow(cui).to receive(:start_session)
        end
        it {
          expect(cui).to receive(:start_session)
          subject
        }

      end

      describe "with sync" do
        let(:args){ [cmd] }
        let(:cmd){ "sync" }

        it {
          expect(cui).to receive(:sync_session)
          subject
        }
      end

      describe "with stop" do
        let(:args){ [cmd] }
        let(:cmd){ "stop" }
        it {
          expect(cui).to receive(:stop_session)         
          subject
        }
      end
    end

    describe "stop_session" do
      subject { cui.stop_session }
      let(:args){ [] }
      let(:machine_obj){ double('machine', :name => "TEST-111").as_null_object }
      let(:session_obj){ double('session').as_null_object }
      before do
        cui.parse_options
        allow(cui).to receive(:get_machine).and_return(machine_obj)
        allow(machine_obj).to receive(:current_session).and_return(session_obj)
        allow(cui).to receive(:print_label).with(session_obj)
        allow(cui).to receive(:sync_session)
      end

      it {
        expect(machine_obj).to receive(:stop)
        subject
      }
      context "with after_stop_command" do
        let(:config){ {:after_stop_command => cmd} }
        let(:cmd){ 'pwd' }
        before do
          allow(cui).to receive(:config).and_return(config)
        end
        it {
          expect(cui).to receive(:system_execute).with(cmd)
          subject
        }  
            
      end
    end

    describe "checkpoint" do
      subject { cui.checkpoint }
      let(:args){ [] }
      let(:config){ {:dst_path => "user@example.com:~/", :src_path => "/cygdrive/u/Users/"} }
      before do
        allow(cui).to receive(:config).and_return(config)
      end
      context "on cygwin" do
        before do
          allow(cui).to receive(:platform).and_return("cygwin")
        end
        it {
          expect(subject).to be_eql("/cygdrive/u/Users/checkpoint.org")
        }
      end
      context "on mingw" do
        before do
          allow(cui).to receive(:platform).and_return("mingw")
        end
        it {
          expect(subject).to be_eql("U:/Users/checkpoint.org")
        }
      end
    end

    describe "get_value_from_config" do
      subject { cui.get_value_from_config(key, default) }
      let(:key){ :before_sync_command }
      let(:default){ nil }
      let(:config){ {:before_sync_command => "hello_cmd"} }
      before do
        allow(cui).to receive(:config).and_return(config)
      end
      it {
        expect(subject).to be_eql("hello_cmd")
      }
      context "without keyword" do
        let(:config){ {:hoge => "hello_cmd"} }
        it {
          expect(subject).to be_nil
        }  
      end
      context "without colon before keyword" do
        let(:config){ {'before_sync_command' => "hello_cmd"} }
        it {
          expect(subject).to be_eql("hello_cmd")
        }  
      end
    end

    describe "after_start" do
      subject { cui.after_start }
      let(:args){ [] }
      let(:config){ {:after_start_command => cmd} }
      let(:cmd){ 'pwd' }
      before do
        allow(cui).to receive(:config).and_return(config)
      end
      it {
        expect(stdout).to receive(:print).with("Are you sure you want to run #{cmd}? [Y/n] ")
        expect(stdout).to receive(:print).with("--> I issued |#{cmd}|")
        expect(stdin).to receive(:gets).and_return("y\n")
        expect(cui).to receive(:system_execute).with(cmd)
        subject
      }
      context "without config" do
        let(:config){ {:hoge => cmd} }
        let(:cmd){ 'pwd' }
        before do
          allow(cui).to receive(:config).and_return(config)
        end
        it {
          expect(stdout).not_to receive(:print).with("Are you sure you want to run #{cmd}? [Y/n] ")
          expect(stdout).not_to receive(:print).with("--> I issued |#{cmd}|")
          expect(stdin).not_to receive(:gets)
          expect(cui).not_to receive(:system_execute).with(cmd)
          subject
        }  
      end
    end

    describe "after_stop" do
      subject { cui.after_stop }
      let(:args){ [] }
      let(:config){ {:after_stop_command => cmd} }
      let(:cmd){ 'pwd' }
      before do
        allow(cui).to receive(:config).and_return(config)
      end
      it {
        expect(stdout).to receive(:print).with("Are you sure you want to run #{cmd}? [Y/n] ")
        expect(stdout).to receive(:print).with("--> I issued |#{cmd}|")
        expect(stdin).to receive(:gets).and_return("y\n")
        expect(cui).to receive(:system_execute).with(cmd)
        subject
      }
      context "without config" do
        let(:config){ {:hoge => cmd} }
        let(:cmd){ 'pwd' }
        before do
          allow(cui).to receive(:config).and_return(config)
        end
        it {
          expect(stdout).not_to receive(:print).with("Are you sure you want to run #{cmd}? [Y/n] ")
          expect(stdout).not_to receive(:print).with("--> I issued |#{cmd}|")
          expect(stdin).not_to receive(:gets)
          expect(cui).not_to receive(:system_execute).with(cmd)
          subject
        }  
      end
    end
    
    describe "before_sync" do
      subject { cui.before_sync }
      let(:args){ [] }
      let(:config){ {:before_sync_command => cmd} }
      let(:cmd){ 'pwd' }
      before do
        allow(cui).to receive(:config).and_return(config)
      end
      it {
        expect(stdout).to receive(:print).with("Are you sure you want to run #{cmd}? [Y/n] ")
        expect(stdout).to receive(:print).with("--> I issued |#{cmd}|")
        expect(stdin).to receive(:gets).and_return("y\n")
        expect(cui).to receive(:system_execute).with(cmd)
        subject
      }
      context "without config" do
        let(:config){ {:hoge => cmd} }
        let(:cmd){ 'pwd' }
        before do
          allow(cui).to receive(:config).and_return(config)
        end
        it {
          expect(stdout).not_to receive(:print).with("Are you sure you want to run #{cmd}? [Y/n] ")
          expect(stdout).not_to receive(:print).with("--> I issued |#{cmd}|")
          expect(stdin).not_to receive(:gets)
          expect(cui).not_to receive(:system_execute).with(cmd)
          subject
        }  
      end
    end

    describe "sync_command" do
      subject { cui.sync_command }
      let(:args){[]}
      let(:config){ {:dst_path => "user@example.com:~/", :src_path => "/cygdrive/u/Users/", :rsync_path => "rsync", :ssh_path => 'ssh'} }
      before do
        allow(cui).to receive(:config).and_return(config)
      end
      it {
        expect(subject).to be_eql("cd #{config[:src_path]} && rsync -rltgoDvh --delete --chmod=u+rwx -e ssh ./ #{config[:dst_path]}")
      }
      context "with drive letter" do
        let(:config){ {:dst_path => "user@example.com:~/", :src_path => "D:/", :rsync_path => "rsync", :ssh_path => 'ssh'} }
        it {
          expect(subject).to be_eql("cd /d #{config[:src_path]} && rsync -rltgoDvh --delete --chmod=u+rwx -e ssh ./ #{config[:dst_path]}")
        }
      end
      context "with ssh_path" do
        let(:config){ {:dst_path => "user@example.com:~/", :src_path => "/cygdrive/u/Users/", :rsync_path => "rsync", :ssh_path => 'ssh'} }
        it {
          expect(subject).to be_eql("cd #{config[:src_path]} && rsync -rltgoDvh --delete --chmod=u+rwx -e ssh ./ #{config[:dst_path]}")
        }
      end
    end

    describe "sync_session" do
      subject { cui.sync_session }
      let(:args){ [] }
      let(:machine_obj){ double('machine', :name => "TEST-111").as_null_object }
      let(:session_obj){ double('session').as_null_object }
      let(:config){ {:dst_path => "user@example.com:~/", :src_path => "C:/cygwin/home/yyachi/orochi-devel", :rsync_path => "rsync", :ssh_path => "ssh"} }
      before do
        allow(cui).to receive(:config).and_return(config)
      end
      it {
        expect(File).to receive(:exists?).with("#{File.join(config[:src_path], "checkpoint.org")}").and_return(true)
        expect(stdout).to receive(:print).with("Are you sure you want to copy #{config[:src_path]} to #{config[:dst_path]}? [Y/n] ")
        expect(stdout).to receive(:print).with("--> I issued |cd /d #{config[:src_path]} && rsync -rltgoDvh --delete --chmod=u+rwx -e ssh ./ #{config[:dst_path]}|")
        expect(stdin).to receive(:gets).and_return("y\n")
        expect(cui).to receive(:system_execute).with("cd /d #{config[:src_path]} && rsync -rltgoDvh --delete --chmod=u+rwx -e ssh ./ #{config[:dst_path]}")
        subject
      }

      context "with mingw ruby" do
        let(:config){ {:dst_path => "user@example.com:~/", :src_path => "/cygdrive/u", :rsync_path => "rsync", :ssh_path => "ssh"} }
        before do
          allow(cui).to receive(:platform).and_return("mingw")
        end
        it {
          expect(File).to receive(:exists?).with("U:/checkpoint.org").and_return(true)
          # expect(stdout).to receive(:print).with("Are you sure you want to copy /cygdrive/u to user@example.com:~/? [Y/n] ")
          expect(stdout).to receive(:print).with("Are you sure you want to copy #{config[:src_path]} to #{config[:dst_path]}? [Y/n] ")
          expect(stdout).to receive(:print).with("--> I issued |cd #{config[:src_path]} && rsync -rltgoDvh --delete --chmod=u+rwx -e ssh ./ #{config[:dst_path]}|")
          expect(stdin).to receive(:gets).and_return("y\n")
          # expect(cui).to receive(:system_execute).with("rsync -rltgoDvh --delete -e ssh /cygdrive/u user@example.com:~/")
          expect(cui).to receive(:system_execute).with("cd #{config[:src_path]} && rsync -rltgoDvh --delete --chmod=u+rwx -e ssh ./ #{config[:dst_path]}")
          subject
        }
      end

      context "without dst_path" do
        let(:config){ {} }
        it {
          expect{ subject }.to raise_error(RuntimeError, /does not have parameter \|dst_path\|/)
        }     
        end

        context "without src_path" do
        let(:config){ {:dst_path => "eee"} }
        it {
          expect{ subject }.to raise_error(RuntimeError, /does not have parameter \|src_path\|/)
        }
      end
      context "without checkpoint" do
        let(:config){ {:dst_path => "user@example.com:~/", :src_path => "C:/Users/dream/Desktop/deleteme.d"} }
        before do
          allow(cui).to receive(:checkpoint_exists?).and_return(false)
        end
        it {
          expect{ subject }.to raise_error(RuntimeError, /Could not find checkpoint file/)
        }
      end

      context "with before_sync_command" do
        let(:config){ {:before_sync_command => cmd, :dst_path => "user@example.com:~/", :src_path => "C:/cygwin/home/yyachi/orochi-devel", :rsync_path => "rsync", :ssh_path => "ssh"} }
        let(:cmd){ 'pwd' }
        before do
          allow(cui).to receive(:config).and_return(config)
        end
        it {
          expect(File).to receive(:exists?).with("#{File.join(config[:src_path], "checkpoint.org")}").and_return(true)
          expect(cui).to receive(:system_execute).with("cd /d #{config[:src_path]} && rsync -rltgoDvh --delete --chmod=u+rwx -e ssh ./ #{config[:dst_path]}")
          expect(cui).to receive(:system_execute).with(cmd)
          subject
        }  
      end
    end

    describe "start_session", :current => true do
      subject { cui.start_session }
      let(:args){ [] }
      let(:machine_obj){ double('machine', :name => "TEST-111").as_null_object }
      let(:session_obj){ double('session').as_null_object }

      before do
        cui.parse_options
        allow(cui).to receive(:get_machine).and_return(machine_obj)
        allow(machine_obj).to receive(:current_session).and_return(session_obj)
        allow(cui).to receive(:print_label).with(session_obj)
      end
      it {
        expect(machine_obj).to receive(:is_running?).and_return(false)
        expect(machine_obj).to receive(:start)
        expect(cui).to receive(:print_label)
        subject
      }
      context "with current_session" do
        before do
          allow(machine_obj).to receive(:is_running?).and_return(true)
          allow(stdin).to receive(:gets).and_return("n\n")
        end

        it {
          expect(stdout).to receive(:print).with("An open session |TEST-111| exists.  Do you want to close and start a new session? [Y/n] ")
          expect{ subject }.to raise_error(SystemExit)
        }
        context "with answer yes" do
          let(:session_obj){ double('session').as_null_object }
          before do
            allow(stdin).to receive(:gets).and_return("y\n")
          end
          it {
            expect(machine_obj).to receive(:stop)
            expect(machine_obj).to receive(:start)
            subject
          }
          context "with message" do
            let(:args){ ["-m", message] }
            let(:message){ "test" }

            it {
              expect(session_obj).to receive(:description=).with(message)
              expect(session_obj).to receive(:save)
              subject
            }
          end
          context "with verbose" do
            let(:args){ ["-v"] }
            it {
              expect(stdout).to receive(:puts).with(session_obj)
              subject
            }
          end
          context "with web" do
            let(:args){ ["-o"] }
            it {
              expect(cui).to receive(:open_browser)
              subject
            }
          end
          context "with after_start_command" do
            let(:config){ {:after_start_command => cmd} }
            let(:cmd){ 'pwd' }
            before do
              allow(cui).to receive(:config).and_return(config)
            end
            it {
              expect(cui).to receive(:system_execute).with(cmd)
              subject
            }  
                
          end
        end 
      end
    end
  end
end

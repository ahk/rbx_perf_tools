# programmatically create rbx memory dump, for use making multiple dumps from within
# one program run, allowing for memory diffs

require 'rubinius/agent'
require 'socket'
require 'tempfile'

# wrapper for Rubinius::Agent
# allows for:
#   grabbing existing agents
#   connecting to them
#   forwarding calls to the wrapped agent
class MyAgent

  attr_reader :pid, :port, :command, :path

  def initialize(pid, port, cmd, path)
    @pid = pid
    @port = port
    @command = cmd
    @path = path
  end

  def connect
    @agent = Rubinius::Agent.connect "localhost", @port
    puts "Connected to localhost:#{@port}, host type: #{@agent.handshake[1]}"
  end

  def dump_tha_heap(i)
    heap_dump_command = 'system.memory.dump'
    heap_out_filename = "heap-#{i}.dump"
    set_config heap_dump_command, heap_out_filename
  end

  def get_config(var)
    var = var.strip

    begin
      kind, val = get(var)
    rescue Rubinius::Agent::GetError => e
      puts "Error: #{e.message}"
      return
    end

    if val.kind_of? Array
      puts "var #{var} = ["
      val.each do |x|
        puts "  #{x.inspect},"
      end
      puts "]"
    else
      puts "var #{var} = #{val.inspect}"
    end
  end

  def set_config(var,val)
    response = @agent.request :set_config, var, val

    case response
    when :ok
      puts "Set var '#{var}' ok."
    when :unknown_key
      puts "Unknown var '#{var}'."
    when :error
      puts "Error setting variable."
    else
      p response
    end
  end

  def quit
    response = @agent.close
    puts response
  end

  def self.find_all
    unless dir = ENV['TMPDIR']
      dir = "/tmp"
      return [] unless File.directory?(dir) and File.readable?(dir)
    end

    agents = Dir["#{dir}/rubinius-agent.*"]

    return [] unless agents

    agents.map do |path|
      pid, port, cmd, exec = File.readlines(path)
      self.new(pid.to_i, port.to_i, cmd.strip, exec.strip)
    end
  end

  def self.connect_first
    agents = self.find_all
    agent = agents.first
    agent.connect
    agent
  end

  def self.cleanup
    unless dir = ENV['TMPDIR']
      dir = "/tmp"
      return [] unless File.directory?(dir) and File.readable?(dir)
    end

    agents = Dir["#{dir}/rubinius-agent.*"]

    return [] unless agents

    agents.map do |path|
      pid, port, cmd, exec = File.readlines(path)
      `kill -0 #{pid}`
      if $?.exitstatus != 0
        puts "Removing #{path}"
        File.unlink path
      end
    end
  end
end


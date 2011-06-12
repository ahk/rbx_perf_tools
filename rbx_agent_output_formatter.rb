require 'json'

module RBXPerf
  class AgentFormatter
    def self.jsonify input
      ha = HeapAnalysis.new input
      ha.parse
      ha.to_json
    end
  end

  class HeapAnalysis
    attr_accessor :source
    attr_reader :counts_constants

    # source is a rubinius heap dump analysis
    def initialize source
      @source = source
      @counts_constants = {}
    end

    def to_json
      self.counts_constants.to_json
    end

    def parse
      @source.each { |line|
        line = line.squeeze ' '
        words = line.split ' '
        # 0: object count, 1: class name, :2 object mem
        # like
        #   25241 Rubinius::Tuple 4396152
        @counts_constants[words[1]] = {:count => words[0], :mem => words[2]}
      }
    end

    def constants
      @counts_constants.keys
    end

  end
end

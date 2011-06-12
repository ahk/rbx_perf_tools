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
    attr_reader :constants_stats

    # source is a rubinius heap dump analysis
    def initialize source
      @source = source
      @constants_stats = []
    end

    def to_json
      JSON.pretty_generate(self.constants_stats)
    end

    def parse
      @source.each { |line|
        line = line.squeeze ' '
        words = line.split ' '
        # 0: object count, 1: constant name, :2 object mem
        # like
        #   25241 Rubinius::Tuple 4396152
        @constants_stats << {
          :constant_name => words[1],
          :count         => words[0],
          :mem           => words[2],
        }
      }
    end

    def constants
      @constants_stats.map {|stats| stats[:constant_name]}
    end

  end
end

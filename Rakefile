require './rbx_agent_output_formatter'

desc "dump heap_analysis to JSON"
task :dump_to_json do
  heap_analysis = File.readlines('fixtures/heap_analysis')
  pretty_json = RBXPerf::AgentFormatter.jsonify heap_analysis
  File.open('heap_analysis.json', 'w') {|f| f.write pretty_json}
end

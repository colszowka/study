module Study
  class Munin  
    attr_reader :graph
    def initialize(graph)
      @graph = graph
    end
  
    def config
      report = []
    
      report << "graph_title #{graph.title}"
      report << "graph_vlabel #{graph.vlabel}"
      report << "graph_category #{graph.category}"
      report << "graph_info #{graph.description}" if graph.description

      graph.keys.each do |scope|
        key = scope.split('.').last
        report << "#{key}.label #{key.capitalize}"
      end
    
      report.join("\n")
    end
  
    def data
      graph.values.map do |key, value|
        "#{key}.value #{value}"
      end.join("\n")
    end
  end
end
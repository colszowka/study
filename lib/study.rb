require "study/version"
require 'redis'

def Study(graph, scope=nil)
  Study.find_graph(graph).increment(scope)
end

module Study
  class UnknownGraphError < StandardError; end;
  class ConfigurationError < StandardError; end;
  class DuplicateGraphError < StandardError; end;
  
  autoload :Graph, File.join(File.dirname(__FILE__), 'study/graph')
  autoload :Munin, File.join(File.dirname(__FILE__), 'study/munin')
  
  class << self
    # Returns an array of all graphs
    def graphs
      _configured_graphs.map {|key, graph| graph }
    end
    
    # Allows you to retrieve a Study::Graph by the given name.
    #
    # Will raise Study::UnknownGraphError if the graph cannot be found.
    def find_graph(name)
      _configured_graphs[name.to_sym] || raise(UnknownGraphError, "No Study graph called '#{name}' is defined!")
    end

    # Returns the redis connection.
    def redis
      @redis ||= Redis.new
    end
    attr_writer :redis
    
    # CAUTION! Will kill all stored data for the current scope ("study.APP_NAME.*")
    def purge!
      redis.keys(scope + "*").each do |key|
         redis.del key
      end
    end
    
    # Returns the configured application name. Used for report group names and redis key scopes.
    #
    # Will raise Study::ConfigurationError if not specified.
    def app_name
      @app_name || raise(Study::ConfigurationError, "Whoops, no app_name specified. Please set one with Study.app_name = 'widgets'")
    end
    attr_writer :app_name
    
    # The scope for the redis keys that study uses.
    def scope
      @scope ||= "study.#{app_name}"
    end
    
    # Allows to define a new graph with given name, returns it after initializing. 
    #
    # If a block is given, the new Study::Graph instance will be yielded to it for further 
    # configuration, i.e.:
    #
    # Study.define_graph :succeeded_jobs do |graph|
    #   graph.title = 'Succeeded Jobs'
    # end
    # 
    # Will raise Study::DuplicateGraphError if the name is already in use.
    #
    def define_graph(name)
      raise DuplicateGraphError, "There already is a graph called '#{name}'!" if _configured_graphs[name.to_sym]
      graph = Study::Graph.new(name)
      _configured_graphs[name.to_sym] = graph
      yield(graph) if block_given?
      graph
    end
    
    private
    
      # Internal storage for graphs, based on a hash for quick retrieval by name
      def _configured_graphs
        @configured_graphs ||= {}
      end
  end
end
module Study
  class Graph
    attr_reader :name
    attr_writer :title, :category, :vlabel
    attr_accessor :description, :absolute
    
    def initialize(name)
      @name = name.to_s.freeze
      @absolute = false
    end
  
    def title
      @title || name
    end
  
    def vlabel
      @vlabel || title
    end
  
    def category
      @category || Study.app_name
    end
  
    def increment(scope=nil)  
      # Always increment total. If there's no scope, this is the only value in the graph
      Study.redis.incr make_scope_key('total')
    
      Study.redis.incr make_scope_key(scope) if scope
    end
  
    def values
      data = {}
      keys.each do |key|
        data[key.split('.').last] = read(key)
      end
      data
    end
  
    def keys
      Study.redis.keys("#{graph_base_scope}\.*")
    end

    private
    
      def read(key)
        if absolute
          get key
        else
          getset key
        end
      end

      # Read the value and reset it to 0. Redis 2.4 will get 0 on getset when null, but earlier versions 
      # may return nil, so enforce a proper return value
      def getset(key)
        Study.redis.getset(key, 0).to_i || 0
      end
      
      # For absolute graphs, just get the key or return 0 without resetting the value
      def get(key)
        Study.redis.get(key).to_i || 0
      end
  
      def make_scope_key(scope)
         if scope.nil?
           graph_base_scope
         else
           "#{graph_base_scope}.#{scope}"
         end
      end
    
      def graph_base_scope
        @graph_base_scope ||= Study.scope + ".#{name}"
      end
  end
end
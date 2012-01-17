require File.join(File.dirname(__FILE__), 'spec_helper')

describe Study, "Configuration" do
  before do
    Study.reset_config!
    Study.app_name = 'widgets'
  end
  
  describe ".app_name" do
    it "must raise an exception when not configured" do
      Study.app_name = nil # Enforce config reset
      lambda { Study.app_name }.must_raise Study::ConfigurationError
    end
    
    it "must be configurable" do
      Study.app_name = 'tokens'
      Study.app_name.must_equal 'tokens'
    end
  end
  
  describe ".scope" do
    it "must consinst of study.APP_NAME" do
      Study.scope.must_equal 'study.widgets'
    end
  end
  
  describe '.define_graph' do
    it 'must return the graph' do
      Study.define_graph('RUMBA').name.must_equal 'RUMBA'
    end
    
    describe "a couple of times without any fancy custom config" do
      before do
        Study.define_graph 'foo'
        Study.define_graph 'bar'
        Study.define_graph 'baz'
      end

      describe ".graphs" do
        it "must return an array with 3 graphs" do
          Study.graphs.must_be_instance_of Array
          Study.graphs.count.must_equal 3
          Study.graphs.each do |graph|
            graph.must_be_instance_of Study::Graph
          end
        end
      end

      describe ".find_graph" do
        it "must work for an existing graph" do
          Study.find_graph('foo').must_be_instance_of Study::Graph
          Study.find_graph('foo').name.must_equal 'foo'
        end

        it "must not work for an unknown graph" do
          lambda { Study.find_graph('unknown') }.must_raise Study::UnknownGraphError
        end
      end
    end
    
    describe "with block-based configuration" do
      before do
        Study.define_graph :foo do |g|
          g.must_be_instance_of Study::Graph
          g.description = 'Foobar'
        end
        Study.find_graph('foo').description.must_equal 'Foobar'
      end
    end
    
    describe "with the same graph defined twice" do
      before do
        Study.define_graph :foo
      end
      
      it "should raise an Study::DuplicateGraphError when defining the same graph again" do
        lambda { Study.define_graph 'foo' }.must_raise Study::DuplicateGraphError
      end
    end
  end

  
  describe ".redis" do
    it "should initialize a new redis connection automatically" do
      Study.redis.must_be_instance_of Redis
    end
    
    it "should accept a custom connection" do
      new_connection = Redis.new
      Study.redis.wont_equal new_connection
      Study.redis = new_connection
      Study.redis.must_equal new_connection
    end
  end
end
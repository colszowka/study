require File.join(File.dirname(__FILE__), 'spec_helper')

describe Study::Graph do
  before do
    Study.reset_config!
    Study.app_name = 'widgets'
    Study.purge!
  end
  
  describe "a graph called 'foo'" do
    before { @graph = Study::Graph.new('foo') }
    
    describe '#name' do
      it("must give it's name") { @graph.name.must_equal 'foo' }
      it "must not allow a change of name" do
        lambda {@graph.name.upcase! }.must_raise RuntimeError
      end
    end
    
    it("should give the name as title") { @graph.title.must_equal @graph.name }
    it("should give the name as vlabel") { @graph.vlabel.must_equal @graph.title }
    it("should give no description") { @graph.description.must_be_nil }
    it("should give the app_name as category") { @graph.category.must_equal Study.app_name }
    
    describe "with modified title" do
      before { @graph.title = 'My New Title' }
      it("should give the custom title") { @graph.title.must_equal 'My New Title' }
      it("should give the title as vlabel") { @graph.vlabel.must_equal @graph.title }
    end
    
    it "should give the custom vlabel when defined" do
      @graph.vlabel = 'Some Vertical Label'
      @graph.vlabel.must_equal 'Some Vertical Label'
    end
    
    it "should give the custom description when defined" do
      @graph.description = 'Some Lenghty Description'
      @graph.description.must_equal 'Some Lenghty Description'
    end
    
    describe "increment" do
      describe "without scope" do
        before { @graph.increment }
        it "should result in 1 key in the popped hash" do
          @graph.values.keys.count.must_equal 1
        end
        
        it "should have the key total with a value of 1" do
          @graph.values['total'].must_equal 1
        end
      end
      
      describe "with 3 different scopes" do
        before do
          20.times { @graph.increment 'mails' }
          30.times { @graph.increment 'updates' }
          50.times { @graph.increment 'clicks' }
        end
        
        it "should result in 4 keys in the popped hash" do
          @graph.values.keys.count.must_equal 4
        end
        
        it "should have the key total with a value of 100" do
          @graph.values['total'].must_equal 100
        end
        
        it "should have the expected values for all specific keys" do
          data = @graph.values
          data['mails'].must_equal 20
          data['updates'].must_equal 30
          data['clicks'].must_equal 50
        end
        
        it "should reset all values after retrieve" do
          @graph.values
          data = @graph.values
          data.length.must_equal 4
          data.each do |key, value|
            value.must_equal 0
          end
        end
        
        it "should return all the appropriate raw keys from redis" do
          @graph.keys.length.must_equal 4
          %w(total mails updates clicks).each do |key|
            @graph.keys.must_include "study.widgets.foo.#{key}"
          end
        end
        
        describe "configured as absolute" do
          before { @graph.absolute = true }
          
          it "should keep values between retrieves" do
            @graph.values['mails'].must_equal 20
            @graph.increment 'mails'
            @graph.values['mails'].must_equal 21
            @graph.values['total'].must_equal 101
          end
        end
      end
    end
  end
end
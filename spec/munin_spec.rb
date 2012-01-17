require File.join(File.dirname(__FILE__), 'spec_helper')

describe Study::Munin do
  before do
    Study.reset_config!
    Study.app_name = 'widgets'
    Study.purge!
  end
  
  describe "initialized with a graph with some data" do
    before do 
      @graph = Study.define_graph 'foo'
      20.times { Study @graph.name, 'mails' }
      30.times { Study @graph.name, 'updates' }
      50.times { Study @graph.name, 'clicks' }
      
      @munin = Study::Munin.new(@graph)
    end

    describe "config" do
      it "should contain the graph_title" do
        @munin.config.split("\n").must_include "graph_title foo"
      end
      it "should contain the graph_vlabel" do
        @munin.config.split("\n").must_include "graph_vlabel foo"
      end
      it "should contain the graph_category" do
        @munin.config.split("\n").must_include "graph_category #{Study.app_name}"
      end
      
      it "should contain the labels for all data points" do
        %w(total mails updates clicks).each do |key|
          @munin.config.split("\n").must_include "#{key}.label #{key.capitalize}"
        end
      end
      
      it "should contain 7 config items in total" do
        @munin.config.split("\n").count.must_equal 7
      end
    end
    
    describe "data" do
      it "should contain all data points and their correct values" do
        data = @munin.data.split("\n")
        data.must_include "total.value 100"
        data.must_include "mails.value 20"
        data.must_include "updates.value 30"
        data.must_include "clicks.value 50"
      end
      
      it "should clean out all data points an data fetch" do
        @munin.data
        @graph.values.each do |key, value|
          value.must_equal 0
        end
      end
    end
    
    describe "and the graph is absolute" do
      before { @graph.absolute = true }
      
      it "should contain all data points and their correct values" do
        data = @munin.data.split("\n")
        data.must_include "total.value 100"
        data.must_include "mails.value 20"
      end
      
      it "should add up to the data points instead of resetting them on multiple retrieves" do
        @munin.data
        30.times { Study @graph.name, :mails }
        
        data = @munin.data.split("\n")
        data.must_include "total.value 130"
        data.must_include "mails.value 50"
      end
    end
  end
end
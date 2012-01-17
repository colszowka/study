# Study

A simple utility for collecting statistics from your application, stuffing
them into Redis and then forwarding them to munin, so it makes nice graphs for you.

For example, collect and graph data on:

  * How many signed in users were active on your site?
  * How many and which background jobs have been processed? How many failed, how many succeeded?
  * How many 404s have been triggered
  * Whatever else you might come up with :)

**Disclaimer: This is still in very early development and should not be considered usable at all**

## Usage

Install using `gem` (or add it to your `Gemfile`:)

    gem install study

Now you need to do some configuration. If you're on Rails, this will probably go into `config/initializers/study.rb`,
otherwise make sure you have this loaded on startup of your Ruby application.

Configure an app name. This will be the default category for your graphs in munin.

    Study.app_name = 'Widgets'

Configure some graphs. This is required since in order to avoid accidental typos on data collection
the graph's previous existince is checked and will raise an exception if the graph has not been defined
before.

The most basic definition looks like this:

    Study.define_graph 'processed_jobs'
    
Now, in your code when you have performed some action that you'd like to be counted, for example you have
finished processing a Resque job successfully, call:

    Study :processed_jobs
    
This will increment the counter for `processed_jobs.total` by 1.

If you want your graph to have more elements than just a generic total, you can pass a second argument,
i.e. holding the job type:

  Study :processed_jobs, 'MailDeliveryJob'
  
This will increment both `processed_jobs.MailDeliveryJob` and `processed_jobs.total` by 1.

## Plugging the data into munin

Now that you collect data, the remaining step is to teach munin how to fetch them.

Unfortunately, automating this is still TODO, altough the basic requirements are in place.

A munin-plugin is basically a shell script that either returns the keys and values or, when called with
the argument `config`, gives the configuration.

A basic plugin may look like this right now (**Note that this will be made easier soon and is just
here to give you a basic idea how this stuff works**)

    #!/usr/bin/env ruby
    
    require 'study'
    require 'PATH/TO/STUDY/CONFIG.rb'
    
    munin = Study::Munin.new(Study.find_graph('widgets'))
    
    if ARGV[0] == 'config'
      puts munin.config
    else
      puts munin.data
    end

This will fetch the graph 'widgets' and either print it's config or the data currently stored in redis.
**If the graph is not configured as `absolute` the counters will all be reset to 0 after fetching this.**
    
## Advanced graph configuration
    
You can pass a block to the define_graph method and configure the graph to your liking (see the API for `Study::Graph`):

    Study.define_graph 'processed_jobs' do |g|
      g.title = 'Some Fancy Title'
      g.vlabel = 'Vertical Label used by Munin graphs'
      g.description = 'Some lenghty description of your graph'
      g.category = 'Override default category, which is the app_name'
      g.absolute = true # Make graph collect absolute numbers instead of relative
    end

## Todo / Ideas

  * Improve the README...
  * Allow for more sophisticated graphs (i.e. fetching current status live, how 
    many jobs in queue, how many records of type XYZ and so on)
  * Other output possibilities than Munin (the basic abstraction should be there, munin is separate from everything else)


## Contributing

1. Fork it and `bundle install`
2. Make sure you have redis running and available on localhost with the default port (so `Redis.new` gets a correct connection)
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Added some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request

require 'make_release/globals'
require 'make_release/options'
require 'make_release/stories'

module MakeRelease
  def self.run!
    begin
      options = Options.parse ARGV
    rescue => error
      puts error
      exit 1
    end

    puts options.inspect if options.debug

    stories = Stories.new(options)

    puts stories.inspect if options.debug

    if options.diff
      puts "From #{stories.directory} branches #{stories.source.join(', ')}"
      puts "All Stories which are not in #{stories.master}..."

      stories.diff.each do |story|
        puts "%-120.120s" % [story.to_s]
      end
    end

  end
end

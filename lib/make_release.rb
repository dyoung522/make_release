require 'make_release/globals'
require 'make_release/options'
require 'make_release/stories'

module MakeRelease
  def self.not_implemented( feature )
    puts "Sorry, #{feature} has not yet been implemented"
    exit 2
  end

  def self.run!
    begin
      opts = Options.parse ARGV
    rescue => error
      puts error
      exit 1
    end

    puts opts.inspect if opts.debug

    if !Dir.exist?(File.join(opts.directory, '.git'))
      puts "There is no git initialized in #{opts.directory}"
    end

    begin
      stories = Stories.new(opts)
    rescue RuntimeError => error
      puts error
      exit 1
    end

    puts stories.inspect if opts.debug

    if opts.diff

      if opts.verbose
        puts "From #{stories.directory}"
        puts "-> All stories from #{stories.source.join(', ')}"
        puts "-> Which are not in #{stories.master}"
        stories.diff.each do |story|
          puts "%-120.120s" % story.to_s
        end
      else
        puts stories.diff.shas
      end

    else

      if opts.verbose
        puts "All stories from #{stories.directory}"
        stories.branches.each do |branch|
          puts "\n#{branch.capitalize}\n\n"
          stories.stories[branch].each do |story|
            puts "%-120.120s" % story.to_s
          end
        end
      else
        not_implemented('--silent')
      end

    end

  end
end


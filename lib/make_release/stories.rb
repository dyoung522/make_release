require 'make_release/story'
require 'make_release/git'

module MakeRelease
  class Stories

    def initialize(opts = Options.defaults)
      @branches = _get_branches(opts[:master], opts[:source])
      @directory = opts[:directory] || '.'
      @includes = _get_includes(opts.includes)
      @options = opts
      @stories = opts[:stories] || {}

      _get_stories if @stories == {}
    end

    attr_accessor :branches, :directory
    attr_reader :stories, :includes

    alias dir directory

    def each
      @stories.values.each do |stories|
        stories.each { |story| yield story }
      end
    end

    def source
      @branches[1, @branches.size]
    end

    def add_include(story)
      @includes << story
    end

    def includes=(file)
      @includes = _get_includes(file)
    end

    def master
      @branches[0]
    end

    def master=(new_master)
      @stories[master] = []
      @branches[0] = new_master
      _get_stories(new_master)
    end

    def shas
      source.map do |branch|
        stories[branch].map { |s| s.sha }
      end.flatten.reverse
    end

    def source_stories
      story_index = {}

      source.each do |branch|
        stories[branch].each { |s| story_index[s.sha] = s }
      end

      story_index.values
    end

    def add_story(branch, story)
      (@stories[branch] ||= []).push story
    end

    def find(branch, sha)
      raise ArgumentError, "Invalid environment #{branch}" unless @branches.include?(branch)

      @stories[branch].each { |story| return true if story.sha == sha }

      false
    end

    def diff
      stories = []
      opts = @options

      source_stories.each do |story|
        stories << story unless find(master, story.sha)
      end

      opts.source = ['diff']
      opts.stories = {'diff' => stories.flatten}
      Stories.new opts
    end

    private

    def _get_branches(master, sources)
      branches = [] << (master.nil? ? 'master' : master)
      branches << (sources.empty? ? ['develop'] : sources)
      branches.flatten
    end

    def _get_includes(includes_file)
      lines = []
      if includes_file && File.exist?(includes_file)
        File.open(includes_file, 'r') do |f|
          f.each_line { |line| lines << $1 if line =~ /(\w+\-\d+)/ }
        end
      end
      lines
    end

    def _get_stories(branches = @branches)
      git = Git.new(@directory)

      branches.to_a.each do |branch|
        puts "checking #{branch}" if @options.debug
        git.log(branch).each do |line|
          add_story branch, Story.new(line)
        end
      end
    end

  end
end


require 'make_release/story'
require 'make_release/git'

module MakeRelease
  class Stories

    def initialize(opts = Options.defaults)
      @options = opts
      @stories = opts[:stories] || {}
      @directory = opts[:directory] || '.'
      @branches = _get_branches(opts[:master], opts[:source])

      _get_stories if @stories == {}
    end

    attr_accessor :branches, :directory
    attr_reader :stories
    alias dir directory

    def each
      @stories.values.each do |stories|
        stories.each { |story| yield story }
      end
    end

    def source
      @branches[1, @branches.size]
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

    def _get_stories(branches = @branches)
      git = Git.new(@directory)

      branches.to_a.each do |branch|
        git.log(branch).each do |line|
          add_story branch, Story.new(line)
        end
      end
    end

  end
end


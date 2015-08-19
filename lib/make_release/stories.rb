require 'make_release/story'
require 'open3'

module MakeRelease
  class Stories

    def initialize( opts = Options.defaults )
      @stories   = {}
      @directory = opts.directory || '.'
      @branches  = _get_branches(opts[:master], opts[:source])

      get_stories
    end
    attr_accessor :branches, :directory
    attr_reader :stories
    alias dir directory

    def source
      @branches[1, @branches.size]
    end

    def master
      @branches[0]
    end

    def master=(new_master)
      @stories[master] = []
      @branches[0] = new_master
      get_stories(new_master)
    end

    def shas
      source.map do |branch|
        stories[branch].map { |s| s.sha }
      end.flatten
    end

    def source_stories
      story_index = {}

      source.each do |branch|
        stories[branch].each { |s| story_index[s.sha] = s }
      end

      story_index.values
    end

    def add( branch, story )
      (@stories[branch] ||= []).push story
    end

    def find( branch, sha )
      raise ArgumentError, "Invalid environment #{branch}" unless @branches.include?(branch)
      @stories[branch].each { |story| return true if story.sha == sha }
      false
    end

    def diff
      stories = []

      source_stories.each do |story|
        stories << story unless find(master, story.sha)
      end

      stories.flatten
    end

    private

    def _get_branches(master, sources)
      branches = [] << (master.nil? ? 'master' : master)
      branches << (sources.empty? ? ['develop'] : sources)
      branches.flatten
    end

    def get_stories(branches = @branches)
      branches.to_a.each do |branch|
        cmd = "git log --oneline --no-merges --pretty='%h|%s' #{branch}"
        Open3.popen3(cmd, chdir: @directory) do |i,o,e,t|
          if t.value != 0
            raise RuntimeError, "Unable to obtain gitlog for #{branch} in #{dir}"
          end
          o.read.split("\n").each { |line| add branch, Story.new(line) }
        end
      end
    end

  end
end


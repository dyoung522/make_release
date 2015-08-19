require 'make_release/story'
require 'open3'

module MakeRelease
  class Stories

    def initialize( opts = {} )
      @stories = {}
      @directory = opts[:directory] || '.'
      @envs = opts[:envs] || [:develop, :master]

      get_stories
    end
    attr_accessor :envs

    def add( env, story )
      (@stories[env.to_sym] ||= []).push story
    end

    def includes?( env, sha )
      raise RuntimeError, "Invalid environment #{env}" unless @envs.include?(env)
      @stories[env.to_sym].each { |story| return true if story.sha == sha }
      false
    end

    def diff( env1 = :develop, env2 = :master)
      unless @envs.include?(env1) && @envs.include?(env2)
        raise RuntimeError, "Invalid environment"
      end

      puts "Stories from '#{@directory}' which are in #{env1} but not #{env2}..."
      @stories[env1.to_sym].each do |story|
        puts "%-120.120s" % story.to_s unless includes?(env2, story.sha)
      end
    end

    private

    def get_stories
      @envs.each do |env|
        cmd = "git log --oneline --no-merges --pretty='%h|%s' #{env}"
        Open3.popen3(cmd, chdir: @directory) do |i,o,e,t|
          if t.value != 0
            raise RuntimeError, "Unable to obtain gitlog for #{env} in #{dir}"
          end
          o.read.split("\n").each { |line| add env, Story.new(line) }
        end
      end
    end

  end
end


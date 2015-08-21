module MakeRelease

  class Story
    def initialize( story )
      unless story =~ /\S+|\S+/
        raise ArgumentError, "story must follow 'SHA|description' format"
      end

      @sha, @description = story.split('|')

      raise ArgumentError if @sha.nil? || @description.nil?
    end
    attr_reader :sha

    def split_story( description = @description )
      raise RuntimeError 'description cannot be blank' unless description

      stories = []
      story_pattern = /\[?(((SRMPRT|OSMCLOUD)\-\d+)|NO-JIRA)\]?[,:\-\s]+\s*(.*)$/
      line = description.match(story_pattern)

      if line.nil? # did not find a JIRA ticket pattern
        stories.push 'NO-JIRA'
        desc = description.strip
      else
        stories.push line.captures[0]
        desc = line.captures[3].strip
      end

      # Perform recursion if there are multiple tickets in the description
      if desc =~ story_pattern
        new_story, new_desc = split_story desc
        stories.push new_story
        desc = new_desc
      end

      [stories.flatten, desc]
    end

    def tickets
      (split_story)[0]
    end

    def desc
      (split_story)[1]
    end

    def to_s
      '[%07.07s] %s - %s' % [sha, tickets.join(', '), desc]
    end

  end
end

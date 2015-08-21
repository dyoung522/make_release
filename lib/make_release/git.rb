require 'open3'

module MakeRelease
  module Git

    def self.log(dir, branch)
      cmd = "git log --no-merges --pretty='%H|%s' #{branch}"
      Open3.popen3(cmd, chdir: dir) do |i,o,e,t|
        if t.value != 0
          raise RuntimeError, "Unable to obtain gitlog for #{branch} in #{dir}"
        end
        o.read.split("\n")
      end
    end

  end
end

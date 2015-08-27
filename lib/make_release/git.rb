require 'open3'

module MakeRelease
  class Git

    def initialize(dir = '.')
      raise StandardError, "Directory '#{dir}' is not valid" unless Dir.exist?(dir)
      raise RuntimeError, "Doesn't look like '#{dir}' is a Git repository" unless Dir.exist?(File.join(dir, '.git'))

      @working_dir = dir
    end

    def log(branch)
      raise RuntimeError, "Invalid branch: #{branch}" unless branch_valid? branch
      run_command("git log --no-merges --pretty='%H|%s' #{branch}")
    end

    private

    def branch_valid?(branch)
      run_command("git branch --list #{branch}").include?(branch)
    end

    def run_command(cmd)
      Open3.popen3(cmd, chdir: @working_dir) do |i, o, e, t|
        raise RuntimeError, "Error on command: #{cmd}" if t.value != 0
        o.read.split("\n")
      end
    end
  end
end

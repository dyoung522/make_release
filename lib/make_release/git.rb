require 'open3'

module MakeRelease
  class Git

    def initialize(dir = '.')
      raise StandardError, "directory #{dir} is not valid" unless Dir.exist?(dir)

      @working_dir = dir
    end

    def log(branch)
      check_branch(branch)
      run_command("git log --no-merges --pretty='%H|%s' #{branch}")
    end

    private

    def check_branch(branch)
      rv = false

      run_command('git branch').each { |b| rv = true if b =~ /#{branch}/ }

      raise RuntimeError, "Invalid branch: #{branch}" unless rv
    end

    def run_command(cmd)
      Open3.popen3(cmd, chdir: @working_dir) do |i, o, e, t|
        raise RuntimeError, "Error on command: #{cmd}" if t.value != 0
        o.read.split("\n")
      end
    end
  end
end

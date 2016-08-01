$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'make_release'

def mock_branch(branch)
  if branch.nil? # Return an empty string (used to test invalid branches)
    allow(Open3).to receive(:popen3).with(/git branch --list/, any_args).and_return([])
  else # Otherwise always return a valid result
    allow(Open3).to receive(:popen3).with("\\git branch --list #{branch}", any_args).and_return([" *#{branch}"])
  end
end

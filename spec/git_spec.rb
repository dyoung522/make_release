require 'spec_helper'
require 'make_release/git'

module MakeRelease
  describe Git do
    let(:sha) { 'a1b2c3e' }
    let(:jira) { 'SRMPRT-12345' }
    let(:desc) { 'this is a description from stories' }
    let(:gitlog_output) { "#{sha}|[#{jira}] #{desc}" }
    let(:git) { Git.new }

    before(:each) do
      allow(Open3).to receive(:popen3).with(/log/, any_args).and_return([gitlog_output])
      mock_branch('master')
      mock_branch('develop')
    end

    context '#new' do
      it 'should raise an error if the directory is not valid' do
        expect { Git.new('foo') }.to raise_error(StandardError)
      end

      it 'should raise an error if the directory is not a Git repo' do
        Dir.mktmpdir('spec-test-') do |dir|
          expect { Git.new(dir) }.to raise_error(RuntimeError)
        end
      end

      it 'should be valid' do
        expect(Git.new).to be_instance_of(Git)
      end
    end

    context '#branch_valid?' do
      it 'returns true for a valid branch' do
        expect(git.branch_valid?('master')).to be_truthy
      end

      it 'returns false for an invalid branch' do
        mock_branch(nil)
        expect(git.branch_valid?('foo')).to be_falsey
      end
    end

    context '#log' do
      it 'raises an error with an invalid branch' do
        mock_branch(nil)
        expect { git.log('foo') }.to raise_error(RuntimeError)
      end

      it 'returns log output with a valid branch' do
        output = git.log('master')

        expect(output).to be_kind_of(Array)
        expect(output[0]).to eq(gitlog_output)
      end
    end

  end
end

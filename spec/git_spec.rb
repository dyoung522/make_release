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
      allow(Open3).to receive(:popen3).with(/branch/, any_args).and_return(['master'])
    end

    context '#log' do
      it 'raises an error with an invalid branch' do
        expect{ git.log('foo') }.to raise_error(RuntimeError)
      end

      it 'returns log output with a valid branch' do
        output = git.log('master')

        expect(output).to be_kind_of(Array)
        expect(output[0]).to eq(gitlog_output)
      end
    end

  end
end

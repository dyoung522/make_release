require 'spec_helper'
require 'make_release/stories'
require 'make_release/git'

module MakeRelease

  describe Stories do
    let(:sha) { 'a1b2c3e' }
    let(:jira) { 'SRMPRT-12345' }
    let(:desc) { 'this is a description from stories' }
    let(:gitlog_output) { "#{sha}|[#{jira}] #{desc}" }
    let(:gitlog) do
      Struct.new(:stdin, :stdout, :stderr, :wait_thr).new(
        Struct.new(:read).new(''),
        Struct.new(:read).new(gitlog_output),
        Struct.new(:read).new(''),
        Struct.new(:value).new(0)
      )
    end
    let(:story) { double Story }
    let(:stories) { Stories.new }

    before(:each) do
      response = [gitlog.stdin, gitlog.stdout, gitlog.stderr, gitlog.wait_thr]
      allow(Open3).to receive(:popen3).and_yield(*response)
    end

    it 'produces a valid object with defaults' do
      expect(stories).to respond_to(:branches)
      expect(stories.branches).to eq(['master', 'develop'])

      expect(stories).to respond_to(:directory)
      expect(stories).to respond_to(:dir) # alias
      expect(stories.directory).to eq('.')
    end

    context '#get_stories' do
      it 'raises a RuntimeError when gitlog fails to run' do
        gitlog.wait_thr.value = 1
        expect { Stories.new }.to raise_error(RuntimeError)
      end
    end

    context '#add_story' do
      it 'adds a Story' do
        expect(stories.stories[:test]).to be_nil
        stories.add_story(:test, story)
        expect(stories.stories[:test]).to eq([story])
      end
    end

    context 'Branches' do
      it 'should return the master branch' do
        expect(stories).to respond_to(:master)
        expect(stories.master).to eq('master')
      end

      it 'should return the source branch(es)' do
        expect(stories).to respond_to(:source)
        expect(stories.source).to eq(['develop'])
      end
    end

    context '#shas' do
      it 'should combine the shas from all source branches into a single list' do
        gitlog.stdout.read = "#{gitlog_output}\n45678|blah\n65432|blah2\n"

        expect(stories).to respond_to(:shas)
        expect(stories.shas).to eq([sha, '45678', '65432'])
      end
    end

    context '#source_stories' do
      it 'should return a combined list of stories from all source branches' do
        gitlog.stdout.read = "#{gitlog_output}\n45678|SRMPRT-456 blah\n65432|SRMPRT-789 blah2\n"

        expect(stories).to respond_to(:source_stories)
        expect(stories.source_stories).to be_kind_of(Array)
        expect(stories.source_stories.count).to eq(3)
      end
    end

    context '#find' do
      it 'raises an error when passed an invalid environment' do
        expect { stories.find(:test, sha) }
          .to raise_error(ArgumentError)
      end

      it 'returns false if sha does not exist' do
        expect(stories.find('develop', '123456')).to eq(false)
      end

      it 'return true when sha exists' do
        expect(stories.find('develop', sha)).to eq(true)
      end
    end

    context '#diff' do
      it 'returns a list of stories not in the master branch' do
        gitlog.stdout.read = "#{gitlog_output}\n45678|SRMPRT-456 blah\n65432|SRMPRT-789 blah2\n"

        stories.stories['master'] = []

        expect(stories).to respond_to(:diff)
        expect(stories.diff).to be_kind_of(Stories)
        expect(stories.diff.branches).to eq(['master', 'diff'])
        expect(stories.diff.stories['diff'].count).to eq(3)
      end

    end
  end
end

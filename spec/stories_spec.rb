require 'spec_helper'
require 'make_release/stories'
require 'make_release/git'

module MakeRelease

  describe Stories do
    let(:sha) { 'a1b2c3e' }
    let(:jira) { 'SRMPRT-12345' }
    let(:desc) { 'this is a description from stories' }
    let(:story) { double Story }
    let(:stories) { Stories.new }

    def mock_gitlog(*output)
      output = ["#{sha}|[#{jira}] #{desc}"] if output.empty?
      allow(Open3).to receive(:popen3).with(/log/, any_args).and_return(output)
    end

    def mock_includes(input)
      file = instance_double File

      allow(File).to receive(:open).and_yield(file)
      allow(File).to receive(:exist?).and_return(true)

      expectation = expect(file).to receive(:each_line)
      input.split("\n").each { |line| expectation.and_yield(line) }

      stories.includes = 'myfile'
    end

    before(:each) do
      mock_gitlog
      mock_branch('master')
      mock_branch('develop')
    end

    it 'should have a directory' do
      expect(stories).to respond_to(:directory)
      expect(stories).to respond_to(:dir) # alias
      expect(stories.directory).to eq('.')
    end

    context 'Includes' do
      it 'should respond to #includes' do
        expect(stories).to respond_to(:includes)
        expect(stories.includes).to be_kind_of(Array)
      end

      context '#includes=' do
        it 'should read in a list of JIRA stories' do
          mock_includes "SRMPRT-12345\nOSMCLOUD-45678"
          expect(stories.includes).to eq(%w(SRMPRT-12345 OSMCLOUD-45678))
        end

        it 'should ignore invalid content' do
          mock_includes "SRMPRT-12345\n789\nOSMCLOUD-45678"
          expect(stories.includes).to eq(%w(SRMPRT-12345 OSMCLOUD-45678))
        end
      end

      context '#add_include' do
        it 'should contain a list of stories' do
          expect(stories).to respond_to(:add_include)
          stories.add_include(jira)
          expect(stories.includes).to include(jira)
        end
      end
    end

    context 'Branches' do
      it 'should have #branches' do
        expect(stories).to respond_to(:branches)
        expect(stories.branches).to eq(%w(master develop))
      end

      it 'should return the master branch' do
        expect(stories).to respond_to(:master)
        expect(stories.master).to eq('master')
      end

      it 'should return the source branch(es)' do
        expect(stories).to respond_to(:source)
        expect(stories.source).to eq(['develop'])
      end
    end

    context '#add_story' do
      it 'adds a Story' do
        expect(stories.stories[:test]).to be_nil
        stories.add_story(:test, story)
        expect(stories.stories[:test]).to eq([story])
      end
    end

    context '#shas' do
      it 'should combine the shas from all source branches into a single list' do
        mock_gitlog '12345|blah', '45678|blah', '65432|blah2'

        expect(stories).to respond_to(:shas)
        expect(stories.shas).to eq(%w(12345 45678 65432).reverse) # Array should be reversed
      end
    end

    context '#source_stories' do
      it 'should return a combined list of stories from all source branches' do
        mock_gitlog '12345|OSMCLOUD-123 foo', '45678|SRMPRT-456 blah', 'n65432|SRMPRT-789 blah2'

        expect(stories).to respond_to(:source_stories)
        expect(stories.source_stories).to be_kind_of(Array)
        expect(stories.source_stories.count).to eq(3)
      end
    end

    context '#find' do
      it 'raises an error when passed an invalid environment' do
        expect { stories.find('test', sha) }.to raise_error(ArgumentError)
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
        mock_gitlog '12345|OSMCLOUD-123 foo', '45678|SRMPRT-456 blah', '65432|SRMPRT-789 blah2'

        stories.stories['master'] = []

        expect(stories).to respond_to(:diff)
        expect(stories.diff).to be_instance_of(Stories)
        expect(stories.diff.branches).to eq(%w(master diff))
        expect(stories.diff.stories['diff'].count).to eq(3)
      end

    end
  end
end

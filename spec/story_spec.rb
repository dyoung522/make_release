require 'spec_helper'
require 'make_release/story'

module MakeRelease
  describe Story do
    let(:sha) { 'a1b2c3e' }
    let(:jira) { 'SRMPRT-12345' }
    let(:desc) { 'this is a description' }
    let(:story) { Story.new("#{sha}|[#{jira}] #{desc}") }

    it 'produces a valid object' do
      expect(story.sha).to eq(sha)
      expect(story.desc).to eq(desc)
    end

    it 'raises an error if not properly initialized' do
      expect {Story.new("this is an invalid input string")}
        .to raise_error(ArgumentError)
    end

    it 'responds to #tickets' do
      expect(story).to respond_to(:tickets)
      expect(story.tickets).to eq([jira])
    end

    it 'responds to #desc' do
      expect(story).to respond_to(:tickets)
      expect(story.desc).to eq(desc)
    end

    it 'responds to #to_s' do
      expect(story).to respond_to(:to_s)
      expect(story.to_s).to eq('[%s] %s - %s' % [sha, jira, desc])
    end

    context '#split_story' do
      it 'produces a valid Array' do
        expect(story.split_story).to be_kind_of(Array)
        expect(story.split_story).to eq([[jira], desc])
      end

      it 'produces multiple tickets when supplied with multiple jira stories' do
        story = Story.new("#{sha}|[#{jira}], [SRMPRT-45678] - #{desc}")
        expect(story.split_story).to be_kind_of(Array)
        expect(story.split_story[0]).to eq([jira, 'SRMPRT-45678'])
      end
    end

  end
end




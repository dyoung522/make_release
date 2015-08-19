require 'spec_helper'

module MakeRelease
  describe MakeRelease do
    it 'has a version number' do
      expect(Globals::VERSION).not_to be nil
    end

    it 'responds to run!' do
      expect(MakeRelease).to respond_to('run!')
    end
  end
end


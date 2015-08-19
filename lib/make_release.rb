require 'make_release/version'
require 'make_release/stories'

module MakeRelease
  def self.run!
    Stories.new(directory: '../modular-engage').diff
  end
end

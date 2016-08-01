module MakeRelease
  module Globals
    require 'yaml'

    VERSION       = '0.2.1'
    IDENT         = 'make_release'
    BINIDENT      = 'mkrelease'
    AUTHOR        = 'Donovan C. Young'
    AEMAIL        = 'dyoung522@gmail.com'
    SUMMARY       = %q{Creates a release candidate}
    DESCRIPTION   = %q{Merges a list of JIRA stories from multiple branches into a release candidate}
    HOMEPAGE      = "https://github.com/dyoung522/#{IDENT}"
    LICENSE       = 'MIT'
    VSTRING       = "#{BINIDENT} v.#{VERSION} - #{AUTHOR}, 2015"
  end
end

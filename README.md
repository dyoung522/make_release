# MakeRelease

This is a standalone utility which will collect multiple JIRA stories and programmatically builds a release candidate branch.
 - Can compare multiple feature branches against a single production branch (typically `master`)
 - Displays the SHAs for all stories not yet merged into production
 - Produce a release-candidate branch


## Installation

Install the `mkrelease` executable

    $ gem install make_release

## Usage

	Usage: mkrelease [options]

    Common Options:
        -d, --directory DIR              Use DIR as our source directory
        -m, --master BRANCH              Specify a master branch (default: master)
        -r, --release-version VER        Specify the release version (REQUIRED)
        -s, --source BRANCH              Use BRANCH as our starting branch to compare against (may be used more than once)
    
    Additional Options:
        -q, --silent                     Run quietly (same as --no-verbose)
        -v, --[no-]verbose               Run verbosely (default)
    
    Informational:
        -h, --help                       Show this message
        -V, --version                    Show version (and exit)
            --diff                       Display a list of stories from all sources which haven't been merged into master
            --dryrun                     Don't actually modify any files, just show what would happen
            --debug                      Run with debugging options (use with caution)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `gem install make_release`. To release a new version, update the version number in `globals.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dyoung522/make_release


require 'ostruct'
require 'optparse'

module MakeRelease
  class Options

    def self.default_options
      {
        directory: '.',
        master:    'master',
        source:    [],
        release:   nil,
        diff:      false,
        dryrun:    false,
        verbose:   true,
        debug:     false,
        stories:   nil
      }
    end

    def self.defaults
      Struct.new( *Options.default_options.keys ).new( *Options.default_options.values )
    end

    def self.parse( argv_opts = [] )
      options = self.defaults

      opt_parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{Globals::BINIDENT} [options]"
        opts.separator ''
        opts.separator 'Common Options:'

        opts.on('-d', '--directory DIR', 'Use DIR as our source directory') do |dir|
          dir = File.expand_path(dir.strip)
          if Dir.exist?(dir)
            options.directory = dir
          else
            raise RuntimeError, "ENOEXIST: Directory does not exist -> #{dir}"
          end
        end

        opts.on('-m', '--master BRANCH', 'Specify a master branch (default: master)') do |master|
          options.master = master
        end

        opts.on('-r', '--release-version VER', 'Specify the release version (REQUIRED)') do |rver|
          options.release = rver
        end

        opts.on('-s', '--source BRANCH',
                'Use BRANCH as our starting branch to compare against (may be used more than once)') do |branch|
          options.source << branch unless options.source.include?(branch)
        end

        opts.separator ''
        opts.separator 'Additional Options:'

        opts.on('-q', '--silent', 'Run quietly (same as --no-verbose)') { options.verbose = false }
        opts.on('-v', '--[no-]verbose', 'Run verbosely (default)') { |v| options.verbose = v }

        opts.separator ''
        opts.separator 'Informational:'

        opts.on('-h', '--help', 'Show this message') { puts Globals::VSTRING + "\n\n"; puts opts;  exit 255; }
        opts.on('-V', '--version', 'Show version (and exit)') { puts Globals::VSTRING;  exit 255; }
        opts.on('-D', '--diff', "Display a list of stories from all sources which haven't been merged into master") { options.diff = true }
        opts.on('--dryrun', %q{Don't actually modify any files, just show what would happen}) { options.dryrun = true }
        opts.on('--debug', 'Run with debugging options (use with caution)') { options.debug = true }
      end

      opt_parser.parse!(argv_opts)

      validate_options(options)
    end

    def self.validate_options(opts)
      # raise OptionParser::MissingArgument, 'A release version (-r) is required' if opts.release.nil?

      if opts.release && opts.release !~ /^v?(\d+\.)?(\d+\.)?(\*|\d+)/
        raise RuntimeError, 'Release version must follow semantic versioning'
      end

      if opts.source.include?(opts.master)
        raise RuntimeError, 'Source branches cannot include the master branch'
      end

      opts.source = ['develop'] if opts.source.empty?
      opts.master = 'master' if opts.master.nil? || opts.master.strip == ''

      opts
    end

  end
end

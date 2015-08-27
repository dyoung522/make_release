require 'ostruct'
require 'optparse'

module MakeRelease
  class Options

    def self.default_options
      {
        debug:     false,
        diff:      false,
        directory: '.',
        dryrun:    false,
        includes:  nil,
        master:    'master',
        release:   nil,
        source:    [],
        tag:       nil,
        stories:   nil,
        verbose:   true
      }
    end

    def self.defaults
      Struct.new(*Options.default_options.keys).new(*Options.default_options.values)
    end

    def self.parse(argv_opts = [])
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
            raise ArgumentError, "ENOEXIST: Directory does not exist -> #{dir}"
          end
        end

        opts.on('-i', '--includes FILE', 'The file container JIRA stories to include, one per line') do |file|
          raise ArgumentError, "ENOEXIST: '#{file}' is not a valid file" unless file && File.exist?(file)
          options.includes = file
        end

        opts.on('-m', '--master BRANCH', 'Specify a master branch (default: master)') { |m| options.master = m }
        opts.on('-r', '--release VER', 'Specify a release version') { |r| options.release = r }

        opts.on('-s', '--source BRANCH',
                'Use BRANCH as the source to compare against (may be used more than once)') do |branch|
          options.source << branch unless options.source.include?(branch)
        end

        opts.on('-t', '--tag TAG', 'Use TAG on release') { |t| options.tag = t }

        opts.separator ''
        opts.separator 'Additional Options:'

        opts.on('-q', '--silent', 'Run quietly (same as --no-verbose)') { options.verbose = false }
        opts.on('-v', '--[no-]verbose', 'Run verbosely (default)') { |v| options.verbose = v }

        opts.separator ''
        opts.separator 'Informational:'

        opts.on('-h', '--help', 'Show this message') { puts Globals::VSTRING + "\n\n"; puts opts; exit 255; }
        opts.on('-V', '--version', 'Show version (and exit)') { puts Globals::VSTRING; exit 255; }
        opts.on('-D', '--diff', "Display a list of stories from all sources which haven't been merged into master") { options.diff = true }
        opts.on('--dryrun', %q{Don't actually modify any files, just show what would happen}) { options.dryrun = true }
        opts.on('--debug', 'Run with debugging options (use with caution)') { options.debug = true }
      end

      opt_parser.parse!(argv_opts)

      validate_options(options)
    end

    def self.validate_options(opts)
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

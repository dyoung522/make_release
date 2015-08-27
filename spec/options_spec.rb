require 'spec_helper'
require 'make_release/git'

module MakeRelease
  describe Options do
    shared_examples 'an option' do |input|
      def run_parse(*opts)
        Options.parse([*opts])
      end

      opts          = input[:opts]
      arg           = input[:arg]
      method        = input[:method]
      desc          = input[:desc] || method
      check_invalid = input[:no_invalid].nil?
      return_val    = input[:returns] || arg
      context       = opts.join(' ')

      context context do

        if arg
          it 'should be valid and require an argument' do
            opts.each do |opt|
              expect { run_parse opt }.to raise_error(OptionParser::MissingArgument)
            end
          end
        else
          it 'should be a valid option' do
            opts.each do |opt|
              expect { run_parse opt }.not_to raise_error
            end
          end
        end

        if method
          if arg
            it "should accept a #{desc}" do
              opts.each do |opt|
                expect(run_parse(opt, arg).send(method)).to eq(return_val)
              end
            end
          end

          if check_invalid
            it "should raise an error if an invalid #{desc} supplied" do
              opts.each do |opt|
                expect { run_parse(opt, 'foo').send(method) }.to raise_error(ArgumentError)
              end
            end
          end
        end
      end
    end

    it_behaves_like 'an option', { opts: %w(-d --directory), arg: '/tmp', method: 'directory' }
    it_behaves_like 'an option', { opts: %w(-i --includes), arg: 'spec/fixtures/test_includes.txt', method: 'includes' }
    it_behaves_like 'an option', { opts: %w(-m --master), arg: 'master', method: 'master', no_invalid: true }
    it_behaves_like 'an option', { opts: %w(-r --release), arg: '0.0.1', method: 'release', no_invalid: true }
    it_behaves_like 'an option', { opts: %w(-s --source), arg: 'develop', method: 'source', no_invalid: true, returns: ['develop'] }
    it_behaves_like 'an option', { opts: %w(-t --tag), arg: 'v0.0.1', method: 'tag', no_invalid: true }
    it_behaves_like 'an option', { opts: %w(-q --silent --no-verbose) }
    it_behaves_like 'an option', { opts: %w(-v --verbose) }

  end
end

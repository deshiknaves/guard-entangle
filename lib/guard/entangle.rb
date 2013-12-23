require 'guard'
require 'guard/plugin'

module Guard
  class Entangle < Plugin

    attr_accessor :options, :runner

    DEFAULTS = {
      :output => 'js',
      :uglify => true,
      :all_on_start => false
    }

    # Initializes a Guard plugin.
    # Don't do any work here, especially as Guard plugins get initialized even if they are not in an active group!
    #
    # @param [Hash] options the custom Guard plugin options
    # @option options [Array<Guard::Watcher>] watchers the Guard plugin file watchers
    # @option options [Symbol] group the group this Guard plugin belongs to
    # @option options [Boolean] any_return allow any object to be returned from a watcher
    #
    def initialize(options = {})
      options = DEFAULTS.merge(options)

      @runner = Runner.new(options)
      super(options)
    end

    # Called once when Guard starts. Please override initialize method to init stuff.
    #
    # @raise [:task_has_failed] when start has failed
    # @return [Object] the task result
    #
    def start
      ::Guard::UI.info 'Guard::Entangle is running'
      run_all if options[:all_on_start]
    end

    # Called when `reload|r|z + enter` is pressed.
    # This method should be mainly used for "reload" (really!) actions like reloading passenger/spork/bundler/...
    #
    # @raise [:task_has_failed] when reload has failed
    # @return [Object] the task result
    #
    def reload
      runner.reload
    end

    # Called when just `enter` is pressed
    # This method should be principally used for long action like running all specs/tests/...
    #
    # @raise [:task_has_failed] when run_all has failed
    # @return [Object] the task result
    #
    def run_all
      _throw_if_failed { runner.run_all }
    end

    # Default behaviour on file(s) changes that the Guard plugin watches.
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_change has failed
    # @return [Object] the task result
    #
    def run_on_changes(paths)
      run_on_modifications(paths)
    end

    # Called on file(s) modifications that the Guard plugin watches.
    #
    # @param [Array<String>] paths the changes files or paths
    # @raise [:task_has_failed] when run_on_modifications has failed
    # @return [Object] the task result
    #
    def run_on_modifications(paths)
      return false if paths.empty?
      ::Guard::UI.info 'Files changed'
      _throw_if_failed { runner.run(paths) }
    end

    def partial?
      File.basename(path).start_with? '_'
    end

    private

    def _throw_if_failed
      throw :task_has_failed unless yield
    end
  end
end

require 'guard/entangle/runner'
require 'guard/entangle/formatter'
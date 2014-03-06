require 'guard/entangle/entangler'
require 'guard/entangle/formatter'
require 'guard/entangle/writer'

module Guard
  class Entangle

    class Runner

      attr_accessor :options

      # Initialize the object
      #
      # @param [hash] options The options passed in
      #
      def initialize(options={})
        @options = options
        @entangler = Entangler.new(options)
        @formatter = Formatter.new
        @writer = Writer.new(options)
      end

      # Run a changed file
      #
      # @param  [array] files Contains the changed file
      # @return [void]
      #
      def run(files)
        # Check if it's a partial
        if partial?(files.first)
          run_all
        else
          # We need to check to see if the input is a
          # directory, else only check that file
          if File.directory?(@options[:input])
            compile_files(files)
          else
            compile(@options[:input])
          end
        end
      end


      # Run all the file(s) that are set in input
      #
      # @return [void]
      #
      def run_all
        paths = options[:input]
        if File.directory?(paths)
          options = @options.merge(@options[:run_all]).freeze
          return if paths.empty?
          ::Guard::UI.info(options[:message], reset: true)
          run_paths(paths, options)
        else
          compile(paths)
        end
      end

      private


      # Run through all the paths
      #
      # @param  [array] paths   The paths array
      # @param  [hash]  options The options
      # @return [void]
      #
      def run_paths(paths, options)
        if paths.kind_of?(Array)
          paths.each do |path|
            process_dir(path, options)
          end
        elsif paths.kind_of?(String)
          process_dir(paths, options)
        else
          ::Guard::UI.info "Paths in configuration are incorrect"
        end
      end


      # Process the entire directory
      #
      # @param  [array] paths   The paths array
      # @param  [hash]  options The options
      # @return [void]
      #
      def process_dir(paths, options)
        return false unless File.directory?(paths)
        skip = %w[. ..];

        cwd = Dir.pwd
        path = "#{cwd}/#{paths}"

        entries = Dir.entries(path)
        entries.each do |file|
          # Skip the dot files and the partials
          if not skip.include?(file) and not partial?(file)
            if File.directory?("#{path}/#{file}")
              process_dir("#{paths}/#{file}", options)
            else
              compile("#{path}/#{file}")
            end
          end
        end
      end


      # Compile each of the files
      #
      # @param [array] files The array of files
      # @return [void]
      #
      def compile_files(files)
        files.each do |file|
          compile(file)
        end
      end


      # Compile a file
      #
      # @param [string] file The file to compile
      # @return [string] The saved file
      #
      def compile(file)
        contents = @entangler.convert(file)
        # save the contents to a file
        if contents
          saved = @writer.output(contents, file)
          if saved
            message = "Successfully compiled and saved #{ saved }"
            @formatter.success(message)
          end
        else
          message = "#{ file } does not exist or is not accessable"
          @formatter.error(message)
        end
        saved
      end

      # Check if the file is a partial or not
      #
      # @param [string] path The path to check
      # @return [boolean] If it is a partial
      #
      def partial?(path)
        File.basename(path).start_with? '_'
      end
    end
  end
end
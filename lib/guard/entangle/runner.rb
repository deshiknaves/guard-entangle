# encoding: utf-8

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
          if File.directory?(options[:input])
            # Check if the output is one file
            if output_dir?
              compile_files(files)
            else
              compile_all(files)
            end
          else
            compile(options[:input])
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
          if output_dir?
            run_paths(paths)
          else
            compile_all(paths)
          end
        else
          compile(paths)
        end
      end

      private


      # Run through all the paths
      #
      # @param  [array] paths   The paths array
      # @return [void]
      #
      def run_paths(paths)
        if paths.kind_of?(Array)
          paths.each do |path|
            process_dir(path)
          end
        elsif paths.kind_of?(String)
          process_dir(paths)
        else
          ::Guard::UI.error "Paths in configuration are incorrect"
        end
      end


      # Process the entire directory
      #
      # @param  [array]  paths        The paths array
      # @param  [boolen] only_compile If the file shouldn't be saved
      # @return [void]
      #
      def process_dir(paths, only_compile = false)
        return false unless File.directory?(paths)
        skip = %w[. ..];

        cwd = Dir.pwd
        path = "#{cwd}/#{paths}"
        compiled = ''

        entries = Dir.entries(path)
        entries.each do |file|
          # Skip the dot files and the partials
          if not skip.include?(file) and not partial?(file)
            if File.directory?("#{path}/#{file}")
              contents = process_dir("#{paths}/#{file}", only_compile)
            else
              contents = compile("#{path}/#{file}", only_compile)
            end
            compiled << contents if only_compile
          end
        end
        if (only_compile)
          return compiled
        end
      end

      # Compile all files and save then in the same file
      #
      # @param  [string] path The input path
      # @return [void]
      #
      def compile_all(path)
        compiled = process_dir(path, true)
        saved = @writer.output(compiled, options[:output])
        if saved
          message = "Successfully compiled and saved #{ options[:output] }"
          @formatter.success(message)
        end
      end


      # Compile each of the files
      #
      # @param  [array] files The array of files
      # @return [void]
      #
      def compile_files(files)
        files.each do |file|
          compile(file)
        end
      end


      # Compile a file
      #
      # @param  [string]  file         The file to compile
      # @param  [boolean] only_compile If the file shouldn't be saved
      # @return [string]               The saved file or contents
      #
      def compile(file, only_compile = false)
        contents = @entangler.convert(file)

        # If we are only compiling
        return contents if only_compile

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
      # @param  [string] path The path to check
      # @return [boolean] If it is a partial
      #
      def partial?(path)
        File.basename(path).start_with? '_'
      end

      # If the output is a directory
      #
      # @return [boolean]
      #
      def output_dir?
        File.extname(options[:output]).empty?
      end
    end
  end
end
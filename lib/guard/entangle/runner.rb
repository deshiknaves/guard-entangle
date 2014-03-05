require 'guard/entangle/entangler'
require 'guard/entangle/formatter'
require 'guard/entangle/writer'

module Guard
  class Entangle

    class Runner

      attr_accessor :options

      def initialize(options={})
        @options = options
        @entangler = Entangler.new(options)
        @formatter = Formatter.new
        @writer = Writer.new(options)
      end

      def run(files)
        compile_files(files)
      end

      def run_all
        paths = options[:input]
        options = @options.merge(@options[:run_all]).freeze
        return if paths.empty?
        ::Guard::UI.info(options[:message], reset: true)
        run_paths(paths, options)
      end

      private

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

      def process_dir(paths, options)
        return false unless File.directory?(paths)
        skip = %w[. ..];

        cwd = Dir.pwd
        path = "#{cwd}/#{paths}"

        entries = Dir.entries(path)
        entries.each do |file|
          if not skip.include?(file)
            if File.directory?("#{path}/#{file}")
              process_dir("#{paths}/#{file}", options)
            else
              compile("#{path}/#{file}")
            end
          end
        end
      end

      def compile_files(files)
        files.each do |file|
          # ::Guard::UI.info "File changed #{file}"
          compile(file)
        end
      end

      def compile(file)
        contents = @entangler.convert(file)
        # save the contents to a file
        if contents
          saved = @writer.output(contents, file)
          message = "Successfully compiled and saved #{ file }"
          @formatter.success(message)
          @formatter.notify(message, { title: 'Entangler results', image: :success })
        else
          message = "#{ file } does not exist or is not accessable"
          @formatter.error(message)
          @formatter.notify(message, { title: 'Entangler results', image: :failed })
        end
        saved
      end
    end
  end
end
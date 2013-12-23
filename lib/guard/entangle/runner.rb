require 'guard/entangle/entangler'

module Guard
  class Entangle

    class Runner

      attr_accessor :options

      def initialize(options={})
        @options = options
        @inspector = Entangler.new(options)
      end

      def run(files)
        changed_files, errors = compile_files(files)
        [changed_files, errors]
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
          process_dir(path, options)
        else
          ::Guard::UI.info "Paths in configuration are incorrect"
        end
      end

      def process_dir(paths, options)
        return false unless File.directory?(paths)
        skip = %w[. ..];
        cwd = Dir.pwd
        entries = Dir.entries("#{cwd}/#{paths}")
        entries.each do |file|
          if not skip.include?(file)
            if File.directory?(file)
              process_dir(true, paths, options)
            else
              compile(file)
            end
          end
        end
      end

      def compile_files(files)
        errors = []
        changed_files = []

        files.each do |file|
          ::Guard::UI.info "File changed #{file}"
          compile(file)
        end
      end

      def compile(file)
        puts "#{file} has been sent for conversion"
      end

    end
  end
end
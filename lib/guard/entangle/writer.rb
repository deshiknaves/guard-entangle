require 'uglifier'
require 'guard/entangle/formatter'

module Guard
  class Entangle

    # The writter class to create an write files
    class Writer

      attr_accessor :options

      def initialize(options={})
        @options = options
        @formatter = Formatter.new
      end

      # Outputs the file in it's needed location
      def output(content, file)
        # Output the file
        cwd = Dir.pwd
        filename = file.gsub "#{cwd}/", ''
        source = filename.split('/').first
        filename.gsub! "#{source}/", ''
        path = "#{cwd}/#{@options[:output]}/#{filename}"
        FileUtils.mkdir_p(File.dirname(path))
        content = format(content, file, path)
        if content
          output = File.new(path, 'w+')
          output.write(content)
          output.close
        end
      end

      def format(content, file, path)
        if File.extname(path) == '.js'
          begin
            content = Uglifier.new(@options[:uglifier]).compile(content)
          rescue
            @formatter.error("Parse error for #{file}")
            return nil
          end
        end
        content
      end
    end
  end
end
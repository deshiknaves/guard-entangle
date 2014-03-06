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

        if @options[:uglify]
          uglify(content, file, path)
        else
          save(content, path)
        end
      end

      # Uglify the js file
      def uglify(content, file, path)
        if File.extname(path) == '.js'
          min = path.gsub(/\.[^.]+$/, '.min.js')
          begin
            content = Uglifier.new(@options[:uglifier_options]).compile(content)
            save(content, min)
          rescue Exception => e
            message = e.message.split(/[\n\r]/).first
            @formatter.error("Uglifier - #{message}")
            return nil
          end

          if @options[:copy]
            save(content, path)
          end
        end
      end

      # Save the file
      def save(content, path)
        if content
          output = File.new(path, 'w+')
          output.write(content)
          output.close
        else
          message = "Content for #{ path } was empty"
          @formatter.error(message)
        end
      end
    end
  end
end
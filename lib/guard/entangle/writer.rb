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
        path = "#{cwd}/#{options[:output]}/#{filename}"

        if File.writable?(path)
          FileUtils.mkdir_p(File.dirname(path))
          # Uglify the files if the flag is set
          if options[:uglify]
            uglify(content, file, path)
          else
            save(content, path)
          end
        else
          message = "The path #{path} is not writable."
          @formatter.error(message)
        end
      end

      # Uglify the js file
      def uglify(content, file, path)
        if File.extname(path) == '.js'
          min = path.gsub(/\.[^.]+$/, '.min.js')
          begin
            uglify = Uglifier.new(options[:uglifier_options]).compile(content)
            save(uglify, min)
          rescue Exception => e
            message = e.message.split(/[\n\r]/).first
            @formatter.error("Uglifier - #{message}")
            return nil
          end

          # If it's specified to keep a copy of the original
          if options[:copy]
            save(content, path)
          end
        end
      end

      # Save the file
      def save(content, path)
        if content
          if File.writable?(path)
            output = File.new(path, 'w+')
            output.write(content)
            output.close
          else
            message = "The path #{path} is not writable."
            @formatter.error(message)
          end
        else
          message = "Content for #{ path } was empty"
          @formatter.error(message)
        end
      end
    end
  end
end
require 'uglifier'
require 'guard/entangle/formatter'

module Guard
  class Entangle

    # The writter class to create an write files
    class Writer

      attr_accessor :options, :cwd

      def initialize(options={})
        @cwd = Dir.pwd
        @options = options
        @formatter = Formatter.new
      end

      # Outputs the file in it's needed location
      def output(content, file)
        # Output the file
        path = get_path(file)
        if create_path?(path)
          if File.writable?(File.dirname(path))
            # Uglify the files if the flag is set
            if options[:uglify]
              uglify(content, file, path)
            else
              save(content, path)
            end
          else
            path.gsub! "#{cwd}/", ''
            message = "The path #{ rel } is not writable."
            @formatter.error(message)
            return
          end
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
        else
          save(content, path)
        end
      end

      # Save the file
      def save(content, path)
        file = path.gsub "#{cwd}/", ''
        if content
          if File.writable?(File.dirname(path))
            output = File.new(path, 'w+')
            output.write(content)
            output.close
            return file
          else
            message = "The path #{ file } is not writable."
            @formatter.error(message)
          end
        else
          message = "Content for #{ file } was empty"
          @formatter.error(message)
        end
      end

      def get_path(file)
        path = "#{cwd}/#{options[:output]}"
        if File.extname(options[:output]).empty?
          filename = file.gsub "#{cwd}/", ''
          source = filename.split('/').first
          filename.gsub! "#{source}/", ''
          path = "#{path}/#{filename}"
        end
        path
      end

      def create_path?(path)
        begin
          FileUtils.mkdir_p(File.dirname(path))
        rescue Exception => e
          message = e.message.split(/[\n\r]/).first
          @formatter.error("Uglifier - #{message}")
          return false
        end
        true
      end
    end
  end
end
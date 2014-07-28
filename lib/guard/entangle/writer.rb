# encoding: utf-8

require 'uglifier'
require 'guard/entangle/formatter'

module Guard
  class Entangle

    # The writter class to create an write files
    class Writer

      attr_accessor :options, :cwd


      # Initialize entangler
      #
      # @param [Hash]   options   The options passed in
      #
      def initialize(options={})
        @cwd = Dir.pwd
        @options = options
        @formatter = Formatter.new
      end


      # Outputs the file in it's needed location
      #
      # @param  [string] content The content to be written
      # @param  [string] file    The file path
      # @return [mixed] path on success else false
      #
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
            puts "here"
            @formatter.error(message)
            return
          end
        end
      end

      private

      # Uglify the js file
      #
      # @param  [string] content The content
      # @param  [string] file    The source file path
      # @param  [string] path    The destination path
      # @return [mixed] path on success, else false
      #
      def uglify(content, file, path)
        if File.extname(path) == '.js'
          min = path.gsub(/\.[^.]+$/, '.min.js')
          begin
            if options[:force_utf8]
              content.encoding
              content.force_encoding 'utf-8'
            end
            uglify = Uglifier.new(options[:uglifier_options]).compile(content)
            save(uglify, min)
          rescue Exception => e
            # Get a readable message
            message = e.message.split(/[\n\r]/).first
            lines = error_lines(content, message)
            @formatter.error("Uglifier - #{message}")
            if lines
              @formatter.error("Surrounding lines:")
              puts lines
            end
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

      # Get the error lines for an uglifier error
      #
      # @param [String] content The content that is being parsed
      # @param [String] message The error message from uglifier
      #
      # @return [mixed] error lines or false
      #
      def error_lines(content, message)
        line = message.match(/line:\s?(\d+),/)

        # The line number is set, we can now get the lines from the file
        if line[1]
          counter = 2
          first = line[1].to_i - options[:error_lines]
          last = line[1].to_i + options[:error_lines]
          file_lines = []

          content.each_line do |item|
            if counter >= first && counter <= last
              item.sub! "\n", ''
              if counter == line[1].to_i
                file_lines << @formatter.colorize("line #{counter}: #{item}", 31)
              else
                file_lines << @formatter.colorize("line #{counter}: #{item}", 33)
              end
            end
            counter += 1
          end
          return file_lines.join("\n")
        end
      end

      # Save the file
      #
      # @param  [string] content The content to write
      # @param  [string] path    The destination file
      # @return [mixed] path on success, else false
      #
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


      # Get the appropriate path depending on the settings
      #
      # @param  [string] file The file path
      # @return [string] The correct file path
      #
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

      # Create the required directories
      #
      # @param  [string] path The file path
      # @return [boolean] If the folder was created
      #
      def create_path?(path)
        begin
          FileUtils.mkdir_p(File.dirname(path))
        rescue Exception => e
          message = "Could not create #{path}. Please check that the directory is writable."
          @formatter.error(message)
          return false
        end
        true
      end
    end
  end
end
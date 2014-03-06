module Guard
  class Entangle
    class Entangler
      attr_reader :options

      # Initialize entangler
      #
      # @param [Hash]   options   The options passed in
      #
      def initialize(options={})
        @options = options
      end

      # Convert the file
      #
      # @param [String]   path    The path of file
      #
      # @return [String]  The entangled content
      #
      def convert(path)
        if not File.exists?(path) or not File.readable?(path)
          return false
        end
        pn = Pathname.new(path)
        file = File.open(path, 'rb')
        contents = file.read
        contents = convert_file(contents, pn.dirname)
      end

      private

      # Convert the file
      #
      # @param [String]   contents    The content to replace in
      # @param [String]   base        The base path
      #
      # @return [String]  The replaced content
      #
      def convert_file(contents, base)
        matches = Set.new search(contents)
        if not matches.empty?
          matches.each do |entry|
            contents = replace(contents, entry, base)
          end
        else
          return contents
        end
        contents
      end

      # Search the contnet for any file hooks
      #
      # @param [String]   contents    The content to search
      #
      # @return [Array]   The array of found hooks
      #
      def search(contents)
        contents.scan(/\/\/=.+$/)
      end

      # Replace the file hook with the contents of the file
      #
      # @param [String]   content   The content of the file
      # @param [String]   file      The file hook
      # @param [String]   path      The base path of the file
      #
      # @return [String]  The replaced content
      #
      def replace(content, file, path)
        name = file.sub '//=', ''
        file = "#{path}/#{name}"
        if File.exists?(file) && File.readable?(file)
          insert = File.open(file, 'rb')
          insert_content = insert.read
          pn = Pathname.new(insert)
          insert = convert_file(insert_content, pn.dirname)
          content.gsub! "//=#{name}", insert_content
        else
          content.gsub! "// #{name}: Does not exist or isn't readable!"
        end
        content
      end
    end
  end
end
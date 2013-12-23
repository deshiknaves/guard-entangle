module Guard
  class Entangle
    class Entangler
      attr_reader :options

      def initialize(options={})
        @options = options
      end

      def convert(path)
        pn = Pathname.new(path)
        file = File.open(path, 'rb')
        contents = file.read
        contents = convert_file(contents, pn.dirname)

        puts contents
      end

      private

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

      def check_file(file)
        puts file
        File.exists?(file)
      end

      def search(contents)
        contents.scan(/\/\/=.+$/)
      end

      def replace(content, file, path)
        name = file.sub '//=', ''
        file = "#{path}/#{name}"
        if check_file(file)
          insert = File.open(file, 'rb')
          insert_content = insert.read
          pn = Pathname.new(insert)
          insert = convert_file(insert_content, pn.dirname)
          content.gsub! "//=#{name}", insert_content
        end
        content
      end
    end
  end
end
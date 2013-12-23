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
        # Match all the //= in all the file
        matches = search(contents)
        if not matches.empty?
          matches.each do |entry|
            contents = replace(contents, entry, pn.dirname)
          end
          puts contents
        end
      end

      private

      def check_file(file)
        File.exists?(file)
      end

      def search(contents)
        contents.scan(/\/\/=.+$/)
      end

      def replace(content, file, path)
        name = file.sub '//=', ''
        file = "#{path}/#{name}"
        puts file
        if check_file(file)
          insert = File.open(file, 'rb')
          insert_content = insert.read
          content.sub! "//=#{name}", insert_content
        end
        content
      end

      def load_file(file)

      end
    end
  end
end
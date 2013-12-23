module Guard
  class Entangle

    class Runner

      attr_reader :options

      def initialize(options={})
        @options   = options
      end

      def run(files)
        changed_files, errors = compile_files(files)
        [changed_files, errors]
      end

      private

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
require 'spec_helper'

describe Guard::Entangle::Writer do
  let(:options) { { output: 'spec/test_output', error_lines: 8 } }
  let(:writer) { Guard::Entangle::Writer.new(options) }
  let(:cwd) { Dir.pwd }

  after {
    # Remove all files after the tests
    base = Dir.pwd
    output_dir = "#{base}/spec/test_output"
    FileUtils.rm_rf output_dir
  }

  describe '#initialize' do
    context 'with custom options' do
      let(:options) { { foo: :bar } }

      it 'sets the options to the passed in options' do
        expect(writer.options).to eq(options)
      end
    end
  end

  describe '#output' do
    it 'has the output directory passed in' do
      expect(writer.options[:output]).to eq('spec/test_output')
    end

    it 'if the output is not wriable' do
      allow(writer).to receive_messages(:create_path? => false)
      allow(::Guard::UI).to receive(:error)

      output = writer.send(:output, '', writer.options[:output])

      expect(output).to eq(nil)
    end

    it 'runs uglify when file is writable' do
      writer.options[:uglify] = true
      allow(writer).to receive_messages(:create_path? => true)
      allow(File).to receive_messages(:writable? => true)
      allow(writer).to receive(:uglify)
      expect(writer).to receive(:uglify)

      writer.output('var = test;', writer.options[:output])
    end

    it 'runs save when file is writable' do
      writer.options[:uglify] = false
      allow(writer).to receive_messages(:create_path? => true)
      allow(File).to receive_messages(:writable? => true)
      allow(writer).to receive(:save)
      expect(writer).to receive(:save)

      writer.output('var = test;', writer.options[:output])
    end
  end

  # There are two errors methods
  describe '#errors' do

    let(:content) {
      <<END
      (function($) {
        console.log('new test');
      }(jQuery));
      (function($) {
        console.log('new test'
      }(jQuery));
END
    }
    let(:message) { 'Uglifier - Unexpected token punc «}», expected punc «,» (line: 5, col: 0, pos: 97)' }

    describe '#error_lines' do

      it 'gets the correct lines when a matched line number found' do

        file_lines = writer.send(:error_lines, content, message)
        count = file_lines.length

        expect(count).to eq(243)
      end

      it "it returns nothing if the line number doesn't exist" do
        message = 'Uglifier - Unexpected token punc «}», expected punc «,» (line: 555, col: 0, pos: 97)'
        file_lines = writer.send(:error_lines, content, message)

        expect(file_lines).to eq(nil)
      end
    end

    describe '#error_line_number' do

      it 'matches line number for an Uglifier error message' do
        line = writer.send(:error_line_number, message)

        expect(line).to eq(5)
      end

      it 'returns null when an incorrect message has been passed' do
        message = 'Uglifier - Unexpected token punc «}», expected punc «,» (lines: 5, col: 0, pos: 97)'
        line = writer.send(:error_line_number, message)

        expect(line).to eq(nil)
      end
    end
  end


  describe '#save' do

    it 'save a file if there is content' do

      allow(::Guard::UI).to receive(:info)
      file = writer.send(:save, 'This is some content', "#{cwd}/spec/test_output")

      expect(file).to eq('spec/test_output')
    end

    it 'throws an error when no content is passed' do

      allow(::Guard::UI).to receive(:error)

      saved = writer.send(:save, nil, "#{cwd}/spec/test_output")

      expect(saved).to eq(nil)
    end

    it 'throws an error when the directory is not writable' do

      allow(File).to receive_messages(:writable? => false)
      allow(::Guard::UI).to receive(:error)

      saved = writer.send(:save, nil, "#{cwd}/spec/test_output")

      expect(saved).to eq(nil)
    end
  end

  describe '#get_path' do
    it 'gets the correct file path for a folder' do
      path = writer.send(:get_path, 'file')

      expect(path).to eq("#{cwd}/#{options[:output]}/file")
    end

    it 'gets the correct file path for a file' do
      path = writer.send(:get_path, 'src/file.js')

      expect(path).to eq("#{cwd}/#{options[:output]}/file.js")
    end
  end

  describe '#create_path?' do
    it 'creates a directory if required' do
      created = writer.send(:create_path?, 'spec/test_output')

      expect(created).to eq(true)
    end

    it "returns false when it can't create the directory" do
      allow(FileUtils).to receive(:mkdir_p).and_raise(Exception)
      allow(::Guard::UI).to receive(:error)

      created = writer.send(:create_path?, 'spec/test_output')

      expect(created).to eq(false)
    end
  end
end
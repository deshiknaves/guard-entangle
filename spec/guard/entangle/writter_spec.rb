require 'spec_helper'

describe Guard::Entangle::Writer do
  let(:options) { { output: 'spec/test_output' } }
  let(:writer) { Guard::Entangle::Writer.new(options) }
  let(:cwd) { Dir.pwd }

  after {
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
      FileUtils.stub(:mkdir_p).and_yield(false)
      ::Guard::UI.stub(:error)
      created = writer.send(:create_path?, 'spec/test_output')

      expect(created).to eq(false)
    end
  end
end
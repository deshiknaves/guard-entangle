require 'spec_helper'

describe Guard::Entangle::Writer do
  let(:options) { { output: 'spec/test_output' } }
  let(:writer) { Guard::Entangle::Writer.new(options) }

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

    it 'has the relative path to the file to save' do
      content = writer.send(:output, contents, 'spec/test_files/subdirectory')
      expect(writer)
    end
  end
end
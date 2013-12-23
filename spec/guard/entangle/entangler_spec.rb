require 'spec_helper'

describe Guard::Entangle::Entangler do
  let(:options) { { output: 'spec/test_output' } }
  let(:entangler) { Guard::Entangle::Entangler.new(options) }
  before {
    allow(Guard::UI).to receive(:info)
  }

  describe '#initialize' do
    context 'with custom options' do
      let(:options) { { foo: :bar } }

      it 'sets the options to the passed in options' do
        expect(entangler.options).to eq(options)
      end
    end
  end

  describe '#convert' do
    it 'converts the given file by inserting the content' do
      entangler.convert('spec/test_files/test1.js')
    end
  end
end
require 'spec_helper'

describe Guard::Entangle::Runner do
  let(:options) { { output: 'spec/test_output' } }
  let(:runner) { Guard::Entangle::Runner.new(options) }
  before {
    allow(Guard::UI).to receive(:info)
  }

  describe '#initialize' do
    context 'with custom options' do
      let(:options) { { foo: :bar } }

      it 'sets the options to the passed in options' do
        expect(runner.options).to eq(options)
      end
    end
  end

  describe '#process_dir' do
    it 'gets all the files to run on ' do
      runner.send(:process_dir, 'spec/test_files', runner.options)
    end
  end
end
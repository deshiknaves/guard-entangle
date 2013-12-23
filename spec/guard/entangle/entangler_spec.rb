require 'spec_helper'

describe Guard::Entangle::Entangler do
  let(:options) { { output: 'spec/test_output' } }
  let(:entangler) { Guard::Entangle::Entangler.new(options) }
  before {
    allow(Guard::UI).to receive(:info)
    base = Dir.pwd
    spec_dir = "#{base}/spec/test_files"

    Dir.mkdir(spec_dir, 0700) unless File.directory?(spec_dir)
    Dir.chdir(spec_dir)
    test = File.new('test.js', 'w+')
    test.write("Test")
    test.close
    test1 = File.new('test1.js', 'w+')
    test1.write("Test 1\n//=test.js\n//=/subdirectory/test2.js")
    test1.close
    sub_dir = "#{spec_dir}/subdirectory"
    Dir.mkdir(sub_dir, 0700) unless File.directory?(sub_dir)
    Dir.chdir(sub_dir)
    test2 = File.new('test2.js', 'w+')
    test2.write("Test 2\n//=../test.js")
    test2.close

    # return the cwd
    Dir.chdir(base)

    # make the output directory
    output = "#{base}/spec/test_output"
    Dir.mkdir(output, 0700) unless File.directory?(output)
  }

  after {
    base = Dir.pwd
    input_dir = "#{base}/spec/test_files"
    output_dir = "#{base}/spec/test_output"
    FileUtils.rm_rf input_dir
    FileUtils.rm_rf output_dir
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
      content = entangler.convert('spec/test_files/test1.js')
      expect(content).to eq(%q{Test 1
Test
Test 2
Test})
    end
  end
end
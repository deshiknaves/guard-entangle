require 'spec_helper'

describe Guard::Entangle::Entangler do
  let(:options) { { output: 'spec/test_output' } }
  let(:entangler) { Guard::Entangle::Entangler.new(options) }
  before {
    allow(Guard::UI).to receive(:info)
    base = Dir.pwd
    spec_dir = "#{base}/spec/test_files"

    Dir.mkdir(spec_dir, 0700)
    Dir.chdir(spec_dir)
    test = File.new('test.js', 'w+')
    test.write("Test")
    test.close
    test1 = File.new('test1.js', 'w+')
    test1.write("Test 1\n//=test.js\n//=/subdirectory/test2.js")
    test1.close
    sub_dir = "#{spec_dir}/subdirectory"
    Dir.mkdir(sub_dir, 0700)
    Dir.chdir(sub_dir)
    test2 = File.new('test2.js', 'w+')
    test2.write("Test 2\n//=../test.js")
    test2.close

    # return the cwd
    Dir.chdir(base)

    # make the output directory
    output = "#{base}/spec/test_output"
    Dir.mkdir(output, 0700)
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

    it 'returns false if the path given does not exist' do
      content = entangler.convert('spec/test_files/file_does_not_exist.js')
      expect(content).to eq(false)
    end
  end

  describe "#convert_file" do

    it "replaces content if file hook is found" do
      file = File.open('spec/test_files/subdirectory/test2.js', 'r')
      contents = file.read
      file.close
      content = entangler.send(:convert_file, contents, 'spec/test_files/subdirectory')
      expect(content).to eq(%q{Test 2
Test})
    end

    it "returns the same content if the matches are empty" do
      contents = 'Test 2'
      content = entangler.send(:convert_file, contents, 'spec/test_files/subdirectory')
      expect(content).to eq(contents)
    end
  end

  describe "#search" do

    it "matches the occourances of file hooks" do
      contents = "Test\n//=File1\n//=File2"
      matches = entangler.send(:search, contents)
      expect(matches.count).to eq(2)
    end

    it "returns empty if there are no occourances" do
      contents = 'Test'
      matches = entangler.send(:search, contents)
      expect(matches.count).to eq(0)
    end
  end
end
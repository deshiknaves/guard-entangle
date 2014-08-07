require 'spec_helper'

describe Guard::Entangle::Runner do
  let(:options) { {
    output: 'spec/test_output',
    input: 'spec/test_files',
    run_all: { message: 'Entangling all files' }
  } }
  let(:runner) { Guard::Entangle::Runner.new(options) }
  let(:writer) { Guard::Entangle::Writer.new(options) }
  let(:formatter) { Guard::Entangle::Formatter.new }
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
        expect(runner.options).to eq(options)
      end
    end
  end

  describe '#process_dir' do
    it 'gets all the files to run on ' do
      runner.send(:process_dir, 'spec/test_files', runner.options)
    end
  end

  describe '#run' do

    it "complies all files if the output is a directory" do
      allow(runner).to receive_messages(:output_dir? => true)
      allow(runner).to receive_messages(:compile_files => 'foo')
      content = runner.send(:run, ['spec/test_files/test.js'])

      expect(content).to eq('foo')
    end

    it "compliles to one file when the output in a directory" do
      allow(runner).to receive_messages(:output_dir? => false)
      allow(runner).to receive_messages(:compile_all => 'foo')
      content = runner.send(:run, ['spec/test_files/test.js'])

      expect(content).to eq('foo')
    end

    it "compiles one file when the input is a file" do
      options[:input] = 'spec/test_output/file.js'
      allow(runner).to receive_messages(:compile => 'foo')
      content = runner.send(:run,  ['spec/test_files/test.js'])

      expect(content).to eq('foo')
    end

    it "runs all when the file is a partial" do
      allow(runner).to receive_messages(:run_all => 'foo')
      content = runner.send(:run, ['spec/test_files/_file.js'])

      expect(content).to eq('foo')
    end

  end

  describe '#run_all' do

    it "it returns nil when paths is empty" do
      options[:input] = 'spec/test_files/'
      content = runner.send(:run_all)

      expect(content).to eq(nil)
    end

    it "compiles all files when the output is a directory" do
      expect(runner).to receive_messages(:run_paths => true)
      content = runner.send(:run_all)

      expect(content).to eq(true)
    end

    it "compiles all files into one when the output is a file" do
      expect(runner).to receive_messages(:compile_all => 'foo')
      options[:output] = 'spec/test_output/file.js'
      content = runner.send(:run_all)

      expect(content).to eq('foo')
    end

    it "runs compile when the input in a file" do
      options[:input] = 'spec/test_files/test.js'
      expect(runner).to receive_messages(:compile => 'foo')
      content = runner.send(:run_all)

      expect(content).to eq('foo')
    end

  end

  describe '#run_paths' do

    it "proecess the directory when the path is a string" do
      expect(runner).to receive_messages(:process_dir => 'foo')
      content = runner.send(:run_paths, 'spec/test_files/test.js')

      expect(content).to eq('foo')
    end

    it "processes each path when the paths in an array" do
      expect(runner).to receive(:process_dir).twice.and_return('foo')
      content = runner.send(:run_paths, ['spec/test_files/test.js', 'spec/test_files/test1.js'])
    end

    it "throws an error if the paths are not a string or an array" do
      expect(::Guard::UI).to receive(:error)
      runner.send(:run_paths, {test: 'foo'})
    end

  end

  describe "#process_dir" do

    it "returns false if the file isn't a directory" do
      process = runner.send(:process_dir, 'spec/test_files/test.js')

      expect(process).to eq(false)
    end

    it "processes all the files in the directory" do
      expect(runner).to receive(:compile).exactly(3).times.and_return('foo')
      compiled = runner.send(:process_dir, 'spec/test_files')
    end

    it "returns the content if only compile is passed in" do
      expect(runner).to receive(:compile).exactly(3).times.and_return('foo')
      compiled = runner.send(:process_dir, 'spec/test_files', true)

      expect(compiled).to eq('foofoofoo')
    end

  end

  describe "#compile_all" do

    it "compiles all files that are in the directory" do

      expect(runner).to receive(:process_dir).exactly(1).times.and_return('foo')
      expect_any_instance_of(Guard::Entangle::Writer).to receive_messages(:output => 'foo')
      expect_any_instance_of(Guard::Entangle::Formatter).to receive(:success)

      runner.send(:compile_all, 'spec/test_files')
    end

  end

  describe "#compile" do

    it "returns the contents if only_compile is true" do
      expect_any_instance_of(Guard::Entangle::Entangler).to receive_messages(:convert => 'foo')
      content = runner.send(:compile, 'spec/test_files/test.js', true)

      expect(content).to eq('foo')
    end

    it "throws an error if the contents of the file is empty" do
      expect_any_instance_of(Guard::Entangle::Entangler).to receive_messages(:convert => nil)
      expect_any_instance_of(Guard::Entangle::Formatter).to receive(:error)
      runner.send(:compile, 'spec/test_files/test.js')
    end

    it "saves a file if content is returned" do
      expect_any_instance_of(Guard::Entangle::Entangler).to receive_messages(:convert => 'foo')
      expect_any_instance_of(Guard::Entangle::Writer).to receive_messages(:output => 'foo')
      expect_any_instance_of(Guard::Entangle::Formatter).to receive(:success)
      runner.send(:compile, 'spec/test_files/test.js')
    end

  end

  describe "#partial?" do

    it "returns true when it is a partial" do
      partial = runner.send(:partial?, 'spec/test_files/_test.js')

      expect(partial).to eq(true)
    end

    it "returns false when it isn't a partial" do
      partial = runner.send(:partial?, 'spec/test_files/test.js')

      expect(partial).to eq(false)
    end

  end

end
require 'spec_helper'

describe Guard::Entangle do

  let(:plugin) { Guard::Entangle.new(options) }
  let(:options) { {} }
  let(:runner) { double(Guard::Entangle::Runner) }
  before {
    allow(Guard::UI).to receive(:info)
    allow(Guard::Entangle::Runner).to receive(:new) { runner }
  }

  describe '#initialize' do

    context 'when no options given' do
      it 'uses defaults' do
        entangle = Guard::Entangle.new()
        expect(entangle.options).to eq(Guard::Entangle::DEFAULTS)
      end
    end

    context 'when options are given' do
      subject {
        opts = {
          :output => 'output',
          :uglify => false
        }
        Guard::Entangle.new(opts)
      }

      it 'merges the passed options with the defaults' do
        subject.options.should == {
          :output       => 'output',
          :input        => 'input',
          :uglify       => false,
          :run_all      => { message: 'Entangling all files' },
          :all_on_start => false
        }
      end
    end
  end

  describe '#start' do
    it "doesn't call #run_all by default" do
      expect(plugin).to_not receive(:run_all)
      plugin.start
    end

    context 'with all_on_start set as true in options' do
      let(:options) { { all_on_start: true } }

      it "calls #run_all" do
        expect(plugin).to receive(:run_all) { true }
        plugin.start
      end
    end
  end

  describe '#run_all' do
    it "runs all specs via the runner" do
      expect(runner).to receive(:run_all) { true }
      plugin.run_all
    end

    it "throws task_has_failed if runner returns false" do
      expect(runner).to receive(:run_all) { false }
      expect(plugin).to receive(:throw).with(:task_has_failed)
      plugin.run_all
    end
  end

  describe "#reload" do
    it "reloads via runner" do
      expect(runner).to receive(:reload)
      plugin.reload
    end
  end

  describe '#run_on_modifications' do

    let(:paths) { %w[path1 path2] }

    it "compiles all files via the runner" do
      expect(runner).to receive(:run).with(paths) { true }
      plugin.run_on_modifications(paths)
    end

    it "does nothing if paths are empty" do
      expect(runner).to_not receive(:run)
      plugin.run_on_modifications([])
    end

    it "throws task_has_failed if runner return false" do
      allow(runner).to receive(:run) { false }
      expect(plugin).to receive(:throw).with(:task_has_failed)
      plugin.run_on_modifications(paths)
    end
  end
end
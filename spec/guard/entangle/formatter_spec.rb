require 'spec_helper'

describe Guard::Entangle::Formatter do

  let(:formatter) { Guard::Entangle::Formatter.new }
  let(:ui) { Guard::UI }
  let(:notifier) { Guard::Notifier }

  describe '#info' do
    it 'outputs an info message' do
      ui.should_receive(:info).with('Info message', { reset: true })
      formatter.info('Info message', { reset: true })
    end
  end

  describe '#debug' do
    it 'outputs a debug message' do
      ui.should_receive(:debug).with('Debug message', { reset: true })
      formatter.debug('Debug message', { reset: true })
    end
  end

  describe '#error' do
    it 'outputs a colorized error message' do
      ui.should_receive(:error).with("\e[0;31mError message\e[0m", { reset: true })
      formatter.error('Error message', { reset: true })
    end
  end

  describe '#success' do
    it 'outputs a coloized success message' do
      ui.should_receive(:info).with("\e[0;32mSuccess message\e[0m", { reset: true })
      formatter.success('Success message', { reset: true })
    end
  end

  describe '#notify' do
    it 'notifies an info message' do
      notifier.should_receive(:notify).with('Notify message', { image: :failed })
      formatter.notify('Notify message', { image: :failed })
    end
  end
end
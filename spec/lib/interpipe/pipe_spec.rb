require 'spec_helper'
require 'interpipe/pipe'

describe Interpipe::Pipe do
  class TestInteractor
    include Interpipe::Interactor
    def perform(key:, **options)
      options
    end
  end
  class TestPipe
    include Interpipe::Pipe
    pipe [
      TestInteractor
    ]
  end

  let(:interactor) { TestInteractor }

  describe '.perform' do
    pending do
      it 'passes result of the previous interactor' do

      end

      it 'returns a result of the last interactor' do
      end
    end
  end

  pending do
    context 'with nested pipe' do
    end
  end

end

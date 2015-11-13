require 'spec_helper'

describe Ar::Services::Resources::ResourceManagerCreator, type: :service, fast: true do

  let(:resource_remover) { double }
  let(:resource_creator) { double }
  let(:action_creator)   { double }
  let(:element)          { double }
  let(:resourceables)    { [resourceable_001, resourceable_002] }
  let(:params)           { {resourceables: resourceables} }
  let(:success_proc)     { ->(r) {} }
  let(:callback)         { {success: success_proc, fail: ->(e) {raise e} } }

  let(:resourceable_001) { double actions_methods: [] }
  let(:resourceable_002) { double actions_methods: []}
  let(:resource_created) { double }

  let(:setup_creators) do
    allow(Ar::Services::Resources::Create::ResourceCreator).to receive(:new).and_return(resource_creator)
    allow(Ar::Services::Actions::Create::ActionCreator).to receive(:new).and_return(action_creator)
  end

  let(:setup_removers) do
    allow(Ar::Services::Resources::Remove::ResourceRemover).to receive(:new).and_return(resource_remover)
  end

  let(:setup_creators_methods) do
    allow(resource_creator).to receive(:create).and_return(resource_created)
    allow(action_creator).to receive(:create_many)
  end

  let(:setup_removers_methods) do
    allow(resource_remover).to receive(:remove_nonexistent_resources)
  end

  let(:result) { subject.create params, callback }

  before do
    setup_creators
    setup_creators_methods
    setup_removers
    setup_removers_methods
    allow(success_proc).to receive(:call)
    result
  end

  it 'resource_remover should call :remove_nonexistent_resources with :resourceables as parameter' do
    expect(resource_remover).to have_received(:remove_nonexistent_resources).with(resourceables).once
  end

  it 'resource_creator should call :create with :resourceable as parameter' do
    expect(resource_creator).to have_received(:create).with(resourceable_001).once
    expect(resource_creator).to have_received(:create).with(resourceable_002).once
  end

  it 'action_creator should call :create_many with :action_params as parameter' do
    expect(action_creator).to have_received(:create_many).with({resource: resource_created, actions_names: []}).twice
  end

  it 'success callback should be called with Array of resources as parameter' do
    expect(success_proc).to have_received(:call).with([resource_created, resource_created])
  end

end
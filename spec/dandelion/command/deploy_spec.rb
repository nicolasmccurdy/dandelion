require 'spec_helper'

describe Dandelion::Command::Deploy do
  let(:config) {{}}
  let(:options) {{}}

  let(:adapter) { double('adapter') }
  let(:workspace) { Dandelion::Workspace.new(test_repo, adapter) }
  let(:command) { Dandelion::Command::Deploy.new(workspace, config, options) }

  describe '#parser' do
    let(:options) { {} }
    let(:parser) { Dandelion::Command::Deploy.parser(options) }

    it 'parses dry flag' do
      expect(options[:dry]).to eq nil
      parser.order!(['--dry-run'])
      expect(options[:dry]).to eq true
    end
  end

  describe '#deployer_adapter' do
    it 'returns workspace adapter' do
      adapter = double('adapter')
      workspace.should_receive(:adapter).and_return(adapter)
      expect(command.deployer_adapter).to eq adapter
    end

    context 'dry run' do
      before(:each) { options[:dry] = true }

      it 'uses no-op adapter' do
        noop = double('no-op adapter')
        Dandelion::Adapter::NoOpAdapter.should_receive(:new).with(command.config).and_return(noop)
        expect(command.deployer_adapter).to eq noop
      end
    end
  end

  describe '#deployer' do
    before(:each) { command.stub(:adapter).and_return(double('adapter')) }

    it 'creates deployer for adapter, and config' do
      deployer = double('deployer')
      Dandelion::Deployer.should_receive(:new).with(command.deployer_adapter, command.config).and_return(deployer)
      expect(command.deployer).to eq deployer
    end
  end

  describe '#setup' do
    it 'sets revision' do
      command.setup([:foo])
      expect(command.config[:revision]).to eq :foo
    end
  end

  describe '#execute!' do
    let(:adapter) { Dandelion::Adapter::NoOpAdapter.new(config) }
    let(:workspace) { Dandelion::Workspace.new(test_repo, adapter) }
    let(:command) { Dandelion::Command::Deploy.new(workspace, config, options) }

    let(:deployer) { double('deployer') }
    let(:changeset) { double('changeset') }

    before(:each) do
      workspace.stub(:changeset).and_return(changeset)
      command.stub(:deployer).and_return(deployer)
    end

    context 'empty changeset' do
      before(:each) { changeset.stub(:empty?).and_return(true) }

      it 'does nothing' do
        deployer.should_not_receive(:deploy!)
      end
    end

    context 'non-empty changeset' do
      before(:each) do
        deployer.stub(:deploy_changeset!)
        changeset.stub(:empty?).and_return(false)
      end

      it 'deploys changeset' do
        deployer.should_receive(:deploy_changeset!).with(changeset)
        command.execute!
      end

      it 'sets remote revision to local revision' do
        workspace.should_receive(:remote_commit=).with(workspace.local_commit)
        command.execute!
      end
    end

    context 'non-empty additional files' do
      before(:each) do
        changeset.stub(:empty?).and_return(true)
      end

      before(:each) do
        deployer.stub(:deploy_files!)
        config[:additional] = ['foo']
      end

      it 'deploys files' do
        deployer.should_receive(:deploy_files!).with(['foo'])
        command.execute!
      end
    end
  end
end
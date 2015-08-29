require 'rails_helper'

describe 'advance phase' do
  include GroupCreator

  let(:service) do
    FeatureService.new(group_repository)
  end
  let(:group_repository) { FakeGroupRepository.new }

  before do
    group_repository.store(before_group)
    group_repository.store(after_group)
  end

  let(:project_id) { 'prj_1' }

  let(:feature_id) { 'feat_123' }

  context 'after group can start new work' do
    let(:before_group) do
      Group(
        project_id: project_id,
        phase: 'Todo',
        wip_limit: nil,
        transition: nil,
        work_list: [[feature_id, nil]]
      )
    end

    let(:after_group) do
      Group(
        project_id: project_id,
        phase: 'Dev',
        wip_limit: 2,
        transition: %w(Doing Review Done),
        work_list: []
      )
    end

    it do
      feature = Feature::FeatureId.new(feature_id)
      before_phase = Work::Phase.new('Todo')
      after_phase = Work::Phase.new('Dev')

      service.advance_phase(project_id, feature, before_phase, after_phase)

      before_group = group_repository.find(project_id, before_phase)
      after_group = group_repository.find(project_id, after_phase)
      expect(before_group.work_list).to be_empty
      expect(after_group.work_list).to eq(
        Work::WorkList.new([Work::Work.new(feature, Work::State.new('Doing'))])
      )
    end
  end
end
__END__

  context 'after group reaches wip limit' do
    let(:before_group) do
      create_group(
        project_id: project_id,
        phase: 'Todo',
        wip_limit: nil,
        transition: nil,
        work_list: [[feature, nil]]
      )
    end

    let(:after_group) do
      create_group(
        project_id: project_id,
        phase: 'Dev',
        wip_limit: 2,
        transition: %w(Doing Review Done),
        work_list: [[]]
      )
    end

    it do
      before_phase = Work::Phase.new('Todo')
      after_phase = Work::Phase.new('Dev')

      service.advance_phase(project_id, feature, before_phase, after_phase)

      before_group = group_repository.find(project_id, before_phase)
      after_group = group_repository.find(project_id, after_phase)
      expect(before_group.work_list).to be_empty
      expect(after_group.work_list).to eq(
        Work::WorkList.new([Work::Work.new(feature, Work::State.new('Doing'))])
      )
    end
  end
end

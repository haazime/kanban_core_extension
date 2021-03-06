require 'rails_helper'

describe FeatureRepository do
  let(:repository) { FeatureRepository.new }
  let(:project_id) { ProjectId('prj_789') }

  describe '#next_number' do
    subject do
      repository.next_number(project_id)
    end

    context 'prj_789.last_number = nil' do
      it { is_expected.to eq(1) }
    end

    context 'prj_789.last_number = nil', 'prj_123.last_number = 1' do
      before do
        ::Feature::Feature.create!(
          project_id: ProjectId('prj_123'),
          feature_id: FeatureId('feat_500'),
          number: 1,
          description_summary: 'Summary',
          description_detail: 'Detail'
        )
      end
      it { is_expected.to eq(1) }
    end

    context 'prj_789.last_number = 1' do
      before do
        ::Feature::Feature.create!(
          project_id: project_id,
          feature_id: FeatureId('feat_100'),
          number: 1,
          description_summary: 'Summary',
          description_detail: 'Detail'
        )
      end
      it { is_expected.to eq(2) }
    end

    context 'prj_789.last_number = 1, prj_123.last_number = 5' do
      before do
        ::Feature::Feature.create!(
          project_id: ProjectId('prj_123'),
          feature_id: FeatureId('feat_500'),
          number: 5,
          description_summary: 'Summary',
          description_detail: 'Detail'
        )
        ::Feature::Feature.create!(
          project_id: project_id,
          feature_id: FeatureId('feat_100'),
          number: 1,
          description_summary: 'Summary',
          description_detail: 'Detail'
        )
      end
      it { is_expected.to eq(2) }
    end

    context 'prj_789.last_number = 7', 'concurrency' do
      before do
        ::Feature::Feature.create!(
          project_id: project_id,
          feature_id: FeatureId('feat_700'),
          number: 7,
          description_summary: 'Summary',
          description_detail: 'Detail'
        )
      end

      let(:add1) do
        ::Feature::Feature.new(
          project_id: project_id,
          feature_id: FeatureId('feat_800-1'),
          number: 8,
          description_summary: 'Summary',
          description_detail: 'Detail'
        )
      end

      let(:add2) do
        ::Feature::Feature.new(
          project_id: project_id,
          feature_id: FeatureId('feat_800-2'),
          number: 8,
          description_summary: 'Summary',
          description_detail: 'Detail'
        )
      end

      it do
        expect(repository.store(add1)).to be_truthy
        expect {
          repository.store(add2)
        }.to raise_error(AssignFeatureNumberError)
      end
    end
  end

  describe '#store' do
    context 'create' do
      it do
        feature = ::Feature::Feature.new(
          project_id: project_id,
          feature_id: FeatureId('feat_555'),
          number: 1,
          description_summary: 'Summary',
          description_detail: 'Detail'
        )
        expect(repository.store(feature)).to be_truthy
      end
    end

    context 'update' do
      let(:feature) do
        ::Feature::Feature.create!(
          project_id: project_id,
          feature_id: FeatureId('feat_555'),
          number: 1,
          description_summary: 'Summary',
          description_detail: 'Detail'
        )
      end

      it do
        feature.start_development
        expect(repository.store(feature)).to be_truthy
      end
    end
  end
end

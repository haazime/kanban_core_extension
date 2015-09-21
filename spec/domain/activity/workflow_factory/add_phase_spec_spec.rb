require 'rails_helper'

module Activity
  describe WorkflowFactory do
    describe '#add_phase_spec' do
      let(:new_workflow) { factory.build_workflow }

      context 'NO current workflow' do
        let(:factory) { described_class.new }

        context 'given phase = Next, transition = none, wip_limit = none' do
          it do
            factory.add_phase_spec(
              Phase('Next'),
              Transition(),
              WipLimit() 
            )
            expect(new_workflow).to eq(
              Workflow([{ phase: 'Next' }])
            )
          end
        end

        context 'given phase = Dev, transition = Doing|Done, wip_limit = 3' do
          it do
            factory.add_phase_spec(
              Phase('Dev'),
              Transition(['Doing', 'Done']),
              WipLimit(3)
            )
            expect(new_workflow).to eq(
              Workflow([
                { phase: 'Dev', transition: ['Doing', 'Done'], wip_limit: 3 }
              ])
            )
          end
        end

        context 'given phase = Deploy, transition = none, wip_limit = 5' do
          it do
            factory.add_phase_spec(
              Phase('Deploy'),
              Transition(),
              WipLimit(5)
            )
            expect(new_workflow).to eq(
              Workflow([{ phase: 'Deploy', wip_limit: 5 }])
            )
          end
        end
      end

      context 'current workflow = Head | Body | Tail' do
        let(:factory) { described_class.new(current) }

        let(:current) do
          Workflow([{ phase: 'Head' }, { phase: 'Body' }, { phase: 'Tail' }])
        end

        context 'add new phase spec' do
          it do
            factory.add_phase_spec(
              Phase('New'),
              Transition(),
              WipLimit()
            )
            expect(new_workflow).to eq(
              Workflow([
                { phase: 'Head' },
                { phase: 'Body' },
                { phase: 'Tail' },
                { phase: 'New' }
              ])
            )
          end
        end

        context 'add Body' do
          it do
            factory.add_phase_spec(
              Phase('Body'),
              Transition(),
              WipLimit()
            )
            expect { new_workflow }.to raise_error(Activity::DuplicatePhase)
          end
        end
      end
    end
  end
end

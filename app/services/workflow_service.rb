class WorkflowService

  def initialize(project_repository, board_repository)
    @project_repository = project_repository
    @board_repository = board_repository
  end

  def add_phase_spec(project_id, attributes, option = nil)
    project = @project_repository.find(project_id)

    factory = Activity::WorkflowBuilder.new(project.workflow)
    phase_spec = Activity::PhaseSpec.new(
      *attributes.values_at(:phase, :transition, :wip_limit)
    )
    add_with_position(option) do |position, base|
      case position
      when :before
        factory.insert_phase_spec_before(phase_spec, base)
      when :after
        factory.insert_phase_spec_after(phase_spec, base)
      else
        factory.add_phase_spec(phase_spec)
      end
    end

    project.specify_workflow(factory.build_workflow)
    @project_repository.store(project)
  end

  def set_transition(project_id, phase, states)
    project = @project_repository.find(project_id)

    workflow_factory = Activity::WorkflowBuilder.new(project.workflow)
    phase_spec_factory = Activity::PhaseSpecBuilder.new(project.workflow.spec(phase))

    phase_spec_factory.set_transition(states)
    workflow_factory.replace_phase_spec(phase_spec_factory.build_phase_spec, phase)
    project.specify_workflow(workflow_factory.build_workflow)

    @project_repository.store(project)
  end

  def remove_phase_spec(project_id, phase)
    project = @project_repository.find(project_id)
    board = @board_repository.find(project_id)

    factory = Activity::WorkflowBuilder.new(project.workflow)
    factory.remove_phase_spec(phase, board)
    project.specify_workflow(factory.build_workflow)

    @project_repository.store(project)
  end

  def remove_state(project_id, phase, state)
    project = @project_repository.find(project_id)
    board = @board_repository.find(project_id)

    workflow_factory = Activity::WorkflowBuilder.new(project.workflow)
    phase_spec_factory = Activity::PhaseSpecBuilder.new(project.workflow.spec(phase))

    phase_spec_factory.remove_state(state, board)
    workflow_factory.replace_phase_spec(phase_spec_factory.build_phase_spec, phase)
    project.specify_workflow(workflow_factory.build_workflow)

    @project_repository.store(project)
  end

  private

    def add_with_position(option)
      position, base = Hash(option).flatten
      yield(position, base)
    end
end

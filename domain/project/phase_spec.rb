module Project
  class PhaseSpec
    attr_reader :phase, :wip_limit

    def initialize(phase, transition, wip_limit)
      @phase = phase
      @transition = transition
      @wip_limit = wip_limit
    end

    def first_situation
      Situation.new(@phase, @transition.first)
    end

    def correct_transition?(before, after)
      @transition.partial?(before.state, after.state)
    end
  end
end

module Kanban
  class PushCard

    def initialize(feature_id, from, to)
      @feature_id = feature_id
      @from = from
      @to = to
    end

    def handle_board(board)
      board.move_card(@feature_id, @from, @to)
    end
  end
end

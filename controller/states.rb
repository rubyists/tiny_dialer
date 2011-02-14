module TinyDialer
  class StatesController < Controller
    map '/states'

    def index
      @states = TinyDialer::State.order(:state)
    end

    def edit
      @state = TinyDialer::State[:id => request["state_id"]]
    end

    def update(id)
      @state = TinyDialer::State[:id => id]
      @state.update(:start => request["start"], :stop => request["stop"])
      flash[:INFO] = "Updated #{@state.state} with start: #{@state.start} and stop: #{@state.stop}"
      redirect r(:index)
    end
  end
end

module TinyDialer
  class Controller < Ramaze::Controller
    layout :default
    helper :xhtml
    engine :Etanni

    before_all do
      name = ENV['APP_DB'].split('_').map(&:capitalize).join(' ')
      @title = "Predictive #{name}"
    end
  end
end

require_relative 'states'
require_relative 'admin'
require_relative 'records'

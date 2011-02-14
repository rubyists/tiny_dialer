# Define a subclass of Ramaze::Controller holding your defaults for all
# controllers

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

# Here go your requires for subclasses of Controller:
require_relative 'states'
require_relative 'admin'
require_relative 'records'

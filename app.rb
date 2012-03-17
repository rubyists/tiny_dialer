require 'json'
require 'ramaze'

ENV['APP_DB'] ||= 'tiny_dialer'

require_relative 'options'
require_relative 'model/init'
require_relative 'lib/tiny_dialer'
require_relative 'lib/tiny_dialer/lead_scrub'
require_relative 'lib/tiny_dialer/state_scrub'
require_relative 'lib/tiny_dialer/zip_scrub'
require_relative 'lib/tiny_dialer/dialer'
require_relative 'lib/tiny_dialer/hopper'
require_relative 'lib/tiny_dialer/phone_number'
require_relative 'lib/tiny_dialer/tcc_helper' if TinyDialer.options.direct_listener.tcc_root
require_relative 'controller/init'

FSR.load_all_commands

Ramaze.start port: 7575 if $0 == __FILE__

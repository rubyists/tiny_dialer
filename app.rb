require 'json'
require 'ramaze'

Ramaze.setup do |g|
  gem 'bacon', '1.1.0'
  gem 'eventmachine', '0.12.10'
  gem 'freeswitcher', '0.6.0', lib: 'fsr'
  gem 'log4r', '1.1.9'
  gem 'name_parse', '0.0.5'
  gem 'pg', '0.10.1'
  gem 'sequel', '3.19.0'
end

require_relative 'options'
require_relative 'lib/tiny_dialer'

module TinyDialer
  require MODEL_ROOT/:init
  require LIBROOT/:tiny_dialer/:csv_scrub
  require LIBROOT/:tiny_dialer/:zip_scrub
  require LIBROOT/:tiny_dialer/:state_scrub
  require LIBROOT/:tiny_dialer/:dialer
  require LIBROOT/:tiny_dialer/:hopper
  require LIBROOT/:tiny_dialer/:phone_number
  require LIBROOT/:tiny_dialer/:tcc_helper if TinyDialer.options.direct_listener.tcc_root
end

require_relative 'controller/init'

Ramaze::Response.options.headers.merge!(
  "Content-Script-Type" => "text/javascript",
  "Content-Style-Type" => "text/css",
  "expires" => "0"
)

FSR.load_all_commands

if $0 == __FILE__
  Ramaze.start port: 7070
end

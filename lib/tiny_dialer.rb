require "pathname"
require 'fsr'

class Pathname
  def /(other)
    join(other.to_s)
  end
end

$LOAD_PATH.unshift(File.expand_path("../", __FILE__))
module TinyDialer
  ROOT = Pathname($LOAD_PATH.first).join("..").expand_path
  LIBROOT = ROOT/:lib
  MIGRATION_ROOT = ROOT/:migrations
  MODEL_ROOT = ROOT/:model
  SPEC_HELPER_PATH = ROOT/:spec

  Log = FSR::Log

  def self.load_fsr
    require "fsr"
  rescue LoadError
    require "rubygems"
    require "fsr"
  end
end

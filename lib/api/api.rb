# frozen_string_literal: true

require 'ffi'

module Proj
  module Api
    ACCEPTABLE_LIB_VERSIONS = %w[19 18 17 16 15 13 12].freeze
    extend FFI::Library
    libraries = [
      'libproj-VERSION', # Mingw64 Proj 6
      'libproj.so.VERSION', # Linuxes
      '/opt/local/lib/proj6/lib/libproj.VERSION.dylib', # Macports
      '/usr/local/lib/libproj.VERSION.dylib' # Mac homebrew
    ].map do |prefix_pattern|
      ACCEPTABLE_LIB_VERSIONS.map do |version_number|
        prefix_pattern.gsub('VERSION', version_number)
      end
    end.flatten

    ffi_lib libraries

    # Load the old deprecated api - supported by all Proj versions (until Proj 7!)
    require_relative './api_4_9'

    library = ffi_libraries.first

    # proj_info was introduced in Proj 5
    if library.find_function('proj_info')
      require_relative './api_5_0'
      PROJ_VERSION = Gem::Version.new(proj_info[:version])
    else
      release = pj_get_release
      version = release.match(/\d\.\d\.\d/)
      PROJ_VERSION = Gem::Version.new(version)
    end
  end

  if Api::PROJ_VERSION < Gem::Version.new('5.0.0')
    def Api.proj_torad(value)
      value * 0.017453292519943296
    end

    def Api.proj_todeg(value)
      value * 57.295779513082321
    end
  end

  require_relative './api_5_1' if Api::PROJ_VERSION >= Gem::Version.new('5.1.0')

  require_relative './api_5_2' if Api::PROJ_VERSION >= Gem::Version.new('5.2.0')

  require_relative './api_6_0' if Api::PROJ_VERSION >= Gem::Version.new('6.0.0')

  require_relative './api_6_1' if Api::PROJ_VERSION >= Gem::Version.new('6.1.0')

  require_relative './api_6_2' if Api::PROJ_VERSION >= Gem::Version.new('6.2.0')
end

# frozen_string_literal: true

require 'mkmf'

dir_config('proj')

unless have_header('proj_api.h', 'definitions.h')
  raise('Cannot find proj_api.h header')
end

have_header('projects.h')

unless have_library('proj', 'pj_init', 'definitions.h') ||
       have_library('libproj', 'pj_init', 'definitions.h')
  raise('Cannot find proj4 library')
end

create_makefile 'proj4_ruby'

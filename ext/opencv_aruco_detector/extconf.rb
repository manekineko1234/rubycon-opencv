# frozen_string_literal: true

require "mkmf"

dir_config("opencv")
pkg_config('opencv4')
have_library('opencv_highgui')
have_library('opencv_objdetect')

create_header
create_makefile("opencv_aruco_detector/opencv_aruco_detector")

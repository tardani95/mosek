cmake_minimum_required(VERSION 2.6.0)

# pull in the pods macros. See cmake/pods.cmake for documentation
set(POD_NAME mosek-pod)
include(cmake/pods.cmake)
include(cmake/matlab_pods.cmake)

# Set up the system name and various paths
if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
	set(PLATFORM_NAME "osx64x86" )
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	execute_process(COMMAND uname -m 
		            OUTPUT_VARIABLE UNAME_M)
	if (${UNAME_M} MATCHES "x86_64")
		set(PLATFORM_NAME "linux64x86" )
	elseif (${UNAME_M} MATCHES "x86")
		set(PLATFORM_NAME "linux32x86" )
	else()
		message(FATAL_ERROR "Unrecognized system variant: ${CMAKE_SYSTEM_NAME} ${UNAME_M}")
	endif()
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	message(FATAL_ERROR "Sorry, I haven't yet been able to support Windows. Please open an issue on the github site if this is important for you.")
else()
	message(FATAL_ERROR "Unrecognized operating system name: ${CMAKE_SYSTEM_NAME}")
endif()

set(DL_PATH "http://download.mosek.com/stable/7")
set(DL_NAME "mosektools${PLATFORM_NAME}.tar.bz2")
set(MOSEK_PLATFORM_PATH "${CMAKE_CURRENT_BINARY_DIR}/mosek/7/tools/platform/${PLATFORM_NAME}")

# Download and unzip the source
if (NOT EXISTS ${MOSEK_PLATFORM_PATH}/h/mosek.h)
	message("Downloading and extracting Mosek files from ${DL_PATH}/${DL_NAME} ...")
	file(DOWNLOAD "${DL_PATH}/${DL_NAME}" "${CMAKE_CURRENT_BINARY_DIR}/${DL_NAME}" SHOW_PROGRESS)
	execute_process(
	     COMMAND ${CMAKE_COMMAND} -E tar xzf "${CMAKE_CURRENT_BINARY_DIR}/${DL_NAME}"
	     WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
	     )
	message("...done")
endif()

# Install support for various languages:

############## C / C++ ###############
pods_install_headers(${MOSEK_PLATFORM_PATH}/h/mosek.h DESTINATION mosek)
add_library(mosek64 SHARED IMPORTED)
set_target_properties(mosek64 PROPERTIES IMPORTED_LOCATION ${MOSEK_PLATFORM_PATH}/bin/ )

############## Python ################
pods_install_python_packages("${MOSEK_PLATFORM_PATH}/python/2/")

############## Matlab ################
pods_configure_matlab_paths()
file(RELATIVE_PATH MOSEK_MATLAB_REL_PATH ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR}/mosek/7/toolbox/r2013a/)
pods_install_matlab_path(mosek ${MOSEK_MATLAB_REL_PATH})
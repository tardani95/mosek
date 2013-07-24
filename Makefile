
default_target: all

# Default to a less-verbose build.  If you want all the gory compiler output,
# run "make VERBOSE=1"
$(VERBOSE).SILENT:

# Figure out where to build the software.
#   Use BUILD_PREFIX if it was passed in.
#   If not, search up to four parent directories for a 'build' directory.
#   Otherwise, use ./build.
ifeq "$(BUILD_PREFIX)" ""
BUILD_PREFIX:=$(shell for pfx in ./ .. ../.. ../../.. ../../../..; do d=`pwd`/$$pfx/build;\
               if [ -d $$d ]; then echo $$d; exit 0; fi; done; echo `pwd`/build)
endif
# create the build directory if needed, and normalize its path name
BUILD_PREFIX:=$(shell mkdir -p $(BUILD_PREFIX) && cd $(BUILD_PREFIX) && echo `pwd`)

# Default to a release build.  If you want to enable debugging flags, run
# "make BUILD_TYPE=Debug"
ifeq "$(BUILD_TYPE)" ""
BUILD_TYPE="Release"
endif

DL_PATH   = http://download.mosek.com/stable/7
UNZIP_DIR = 7
ifeq ($(shell uname -s), Darwin)
  DL_NAME = mosektoolsosx64x86.tar.bz2
else ifeq ($(shell uname -s), Linux)
  ifeq ($(shell uname -m), x86_64)
    DL_NAME = mosektoolslinux64x86.tar.bz2
  else
    DL_NAME = mosektoolslinux32x86.tar.bz2
  endif
else 
  # throw an error?
endif

all: $(UNZIP_DIR) $(BUILD_PREFIX)/matlab/addpath_mosek.m $(BUILD_PREFIX)/matlab/rmpath_mosek.m $(HOME)/mosek/mosek.lic

$(UNZIP_DIR):
	wget --no-check-certificate $(DL_PATH)/$(DL_NAME) && tar -xjf $(DL_NAME) -C .. && rm $(DL_NAME)

# note that there are only two folders (r2012a, r2013a) on mac, but there are more on linux.  i've only supported the two below
$(BUILD_PREFIX)/matlab/addpath_mosek.m : Makefile
	@mkdir -p $(BUILD_PREFIX)/matlab
	echo "Writing $(BUILD_PREFIX)/matlab/addpath_mosek.m"
	echo "function addpath_mosek()\n\n \
		if verLessThan('matlab','8.1')\n \
		  if verLessThan('matlab','7.14'),\n \
		    error('Mosek requires MATLAB 7.14 (R2012a) or higher');\n \
		  else\n \
		    d='r2012a';\n \
		  end\n \
		else\n \
	          d='r2013a';\n \
	        end\n \
		addpath(fullfile('$(shell pwd)','7','toolbox',d));\n" \
		> $(BUILD_PREFIX)/matlab/addpath_mosek.m

$(BUILD_PREFIX)/matlab/rmpath_mosek.m : Makefile
	@mkdir -p $(BUILD_PREFIX)/matlab
	echo "Writing $(BUILD_PREFIX)/matlab/rmpath_mosek.m"
	echo "function rmpath_mosek()\n\n \
		if verLessThan('matlab','8.1')\n \
		  if verLessThan('matlab','7.14'),\n \
		    error('Mosek requires MATLAB 7.14 (R2012a) or higher');\n \
		  else\n \
		    d='r2012a';\n \
		  end\n \
		else\n \
	          d='r2013a';\n \
	        end\n \
		rmpath(fullfile('$(shell pwd)','7','toolbox',d));\n" \
		> $(BUILD_PREFIX)/matlab/rmpath_mosek.m

# todo: make this logic more robust:
#   check for license path environment variable
#   check expiration date in mosek.lic if it is found
$(HOME)/mosek/mosek.lic : 
	@echo "You do not appear to have a license for mosek installed in $(HOME)/mosek/mosek.lic\n"
	@echo "Open the following url in your favorite browser and request the license:\n"
	@echo "           http://license.mosek.com/license2/academic/\n"
	@echo "Then check your email for the license file and put it in $(HOME)/mosek/mosek.lic\n"

clean:
	-rm $(BUILD_PREFIX)/matlab/*path_mosek.m

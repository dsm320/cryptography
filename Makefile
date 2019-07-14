# Standard Makefile for a C++ project that compiles each .cc file into a .o
# file, and then links .o files together to produce an executable.  This version
# is modified slightly, so that it can make multiple executables.  The breakdown
# is some common code, in the "CXXFILES" list of files, and then
# some per-executable code, in the "TARGETS" files.  All of the common code goes
# into every executable, which is probably a little bit wasteful, but not bad
# enough to justify any more complexity in this Makefile.

# names of .cc files that have a main() function
TARGETS = aes_crypt rsa_crypt

# names of .cc files that are used by all of the above targets
CXXFILES = # no common files :)

#
# The rest of this file should never need to change
#

# Let the programmer choose 32 or 64 bits, but default to 64 bit
BITS ?= 64

# Specify the name of the folder where all output will go
ODIR := ./obj$(BITS)

# This line ensures that the above folder will be created before any compiling
# happens.
output_folder := $(shell mkdir -p $(ODIR))

# Generate the names of the .o files and .exe files that will be created
# Note that all .o files explicitly are named explicitly, so that they can be added to the
# .PRECIOUS target, which prevents them from being auto-removed.
COMMONOFILES = $(patsubst %, $(ODIR)/%.o, $(CXXFILES)) # NB: These get linked into every executable
ALLOFILES    = $(patsubst %, $(ODIR)/%.o, $(CXXFILES) $(TARGETS))
EXEFILES     = $(patsubst %, $(ODIR)/%.exe, $(TARGETS))

# Generate the names of the dependency files that G++ will generate, so that they can be
# included later in this makefile
DFILES     = $(patsubst %.o, %.d, $(ALLOFILES))

# Basic tool configuration for GCC/G++.  Create debug symbols, enable
# optimizations, and generate dependency information on-the-fly
CXX      = g++
LD       = g++
CXXFLAGS = -MMD -O3 -m$(BITS) -ggdb -std=c++17 -Wall -Werror
LDFLAGS  = -m$(BITS) -lpthread -lcrypto

# Build 'all' by default, and don't clobber .o files after each build
.DEFAULT_GOAL = all
.PRECIOUS: $(ALLOFILES)
.PHONY: all clean

# Goal is to build all executables
all: $(EXEFILES)

# Rules for building object files
$(ODIR)/%.o: %.cc
	@echo "[CXX] $< --> $@"
	@$(CXX) $< -o $@ -c $(CXXFLAGS)

# Rules for building executables... assume an executable uses *all* of the 
# common OFILES
$(ODIR)/%.exe: $(ODIR)/%.o $(COMMONOFILES)
	@echo "[LD] $^ --> $@"
	@$(CXX) $^ -o $@ $(LDFLAGS)

# clean by clobbering the build folder
clean:
	@echo Cleaning up...
	@rm -rf $(ODIR)

# Include any dependencies previously generated
-include $(DFILES)
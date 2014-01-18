# A Generic Makefile for ADMB programs that also includes additonal libraries.
# Developed for Mac OSx using the clang++ compiler
# Author: Steve Martell & John Sibert
# —————————————————————— INSTRUCTIONS ———————————————————————— #
# 1. Set the EXEC variable to the name of the program.         #
# 2. List additional .cpp files required by EXEC in SRCS macro #
# 3. Set the ADMB_HOME path to your distribution of ADMB.      #
# 4. To make executables with ADMB "safe" library type: make   #
# 5. Optimized executables type: make OPT=TRUE                 #
# ———————————————————————————————————————————————————————————— #
EXEC = pella-xml
SRCS = $(EXEC).cpp ADMB_XMLDoc.cpp 
OBJS = $(SRCS:.cpp=.o)
TPLS = $(EXEC).tpl
DEPS = $(SRCS:.cpp=.depends)

# Export the path to your ADMB dist directory
export ADMB_HOME=/home/jsibert/admb/trunk/build/dist

# establish the C++ compiler (on Mac OSX use clang++)
CC=gcc
CXX=g++
# and linker
LL = $(CC)
LD = $(CXX)
# Remove macro
RM=rm -fv

# identify some extra file name suffixes
.SUFFIXES: .tpl .cpp .o .obj

# tell make not to delete these intermediate targets
.PRECIOUS: %.cpp %.o %.obj

# make some special PHONY targets
.PHONY: all help rules clean

# set up ADMB flags and appropriate libraries
# make the "safe" version by default
# to make "the optimized" version, type  `make OPT=TRUE
ifeq ($(OPT),TRUE)
  CC_OPT = -O3 -DOPT_LIB
  LDFLAGS = -O3 
  LDLIBS  = $(ADMB_HOME)/lib/libadmbo.a $(ADMB_HOME)/contrib/lib/libcontribo.a -lxml2
else
  CC_OPT = -O3 -DSAFE_ALL -ggdb
  LDFLAGS = -O3 -g
  LDLIBS  = $(ADMB_HOME)/lib/libadmb.a $(ADMB_HOME)/contrib/lib/libcontrib.a -lxml2
endif

# set general compiler flags
CXXFLAGS = $(CC_OPT) -D__GNUDOS__ -Dlinux -DUSE_LAPLACE  -I. -I$(ADMB_HOME)/include -I$(ADMB_HOME)/contrib/include -I/usr/include/libxml2 


# this is the default target
all: $(EXEC)

# link the object file into the executable 
$(EXEC): $(OBJS)
	$(LD) $(LDFLAGS) -o  $@ $(OBJS) $(LDLIBS)


# Advanced Auto Dependency Generation
# Check compiler options for generating phony targets (-MP -MD for clang compiler on OSX)
%.o : %.cpp
	$(CXX) -MP -MD -c -o $@ $< $(CXXFLAGS)

-include $(OBJS:%.o=%.d)

# Build the cpp file from the tpl
$(EXEC).cpp: $(TPLS)
	$(ADMB_HOME)/bin/tpl2cpp $(TPLS:.tpl=)



clean: 
	$(RM) $(OBJS) $(EXEC).htp $(EXEC).cpp
	$(RM) $(EXEC).bar  $(EXEC).cor  $(EXEC).eva  $(EXEC).log  $(EXEC)-log.log  $(EXEC).par  $(EXEC).rep  $(EXEC).std
	$(RM) admodel.*
#$(RM) $(EXEC).x00  $(EXEC).x01


# generate some information about what your are doing
rules:
	@echo EXEC = $(EXEC)
	@echo OBJS = $(OBJS)
	@echo SRCS = $(SRCS)
	@echo TPLS = $(TPLS)
	@echo OPT = $(OPT)
	@echo CC_OPT = $(CC_OPT)
	@echo PWD = $(PWD)
	@echo ADMB_HOME = $(ADMB_HOME)
	@echo CC = $(CC)
	$(CC) --version
	@echo LD = $(LD)
	@echo CXXFLAGS = $(CXXFLAGS)
	@echo LDFLAGS = $(LDFLAGS)


# Some help for the naive
help:
	@echo Set:   EXEC target to the BaseName of your tpl script.
	@echo Usage: make <OPT=TRUE>
	@echo        specify OPT=TRUE to build optimized version




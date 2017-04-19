# CS 486 
# Brigham Young University

# NOTE: You need to configure the CUDD variable to point to your 
# install location.  This should be the path to the build directory.
# See the README file for details on how to build and configure CUDD
#
# YOU NEED TO CONFIGURE THIS TO YOUR SYSTEM

CUDD	= /home/sir/Code/byu-verification-validation/cudd/cudd-3.0.0

# You should not need to change the rest of these variable definitions
# to use CUDD

 CUDDINC	= -I$(CUDD)/include
 CUDDLIB	= -L$(CUDD)/lib
CUDDLIBS	= -lcudd -lobj 
    OBJS	=  cudd-example.o
 DEFINES	= -D USE_CUDD

# These are definitions to use your own BDD package.  You should not need
# to change any of these unless I left off an object file.

# You may need to change these for your particular environment (i.e.,
# nonUnix based).

CC 		= clang++ 
CFLAGS 		= -g -Wall $(DEFINES) -std=c++0x 

# Simple name a different target to change default 'make' behavior
# when no target is specified.

DEFAULT		= cudd-example

########################################################################
# BUILD TARGETS
########################################################################

default:	$(DEFAULT)

%.o:	%.cc
		$(CC) $(CFLAGS) $(CUDDINC) -c $<

cudd-example:	$(OBJS)
			$(CC) $(CFLAGS) $(OBJS) -o cudd-example $(CUDDLIB) $(CUDDLIBS)

clean:
	rm -f *.o *~ cudd-example

# EDCommon.framework
# GNUmakefile
#
# $Id: GNUmakefile,v 2.4 2005-09-26 12:14:56 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

# Install into the local root by default
GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_LOCAL_ROOT)

include $(GNUSTEP_MAKEFILES)/common.make


FRAMEWORK_NAME = EDCommon


EDCommon_HEADER_FILES = \
EDCommon.h \
EDCommonDefines.h \
EDObjcRuntime.h \
osdep.h


EDCommon_OBJC_FILES = \
framework.m \
useful.m


EDCommon_SUBPROJECTS = \
FoundationExtensions.subproj \
DataStructures.subproj


# AppKitExtensions.subproj and Widgets.subproj should be built
# ONLY if library-combo ends with something different than "nil"

ifneq "$(GUI_LIB)" "nil"
EDCommon_SUBPROJECTS += AppKitExtensions.subproj Widgets.subproj
endif


include GNUstepBuild


# Additional target specific settings

# FreeBSD
ifeq "$(GNUSTEP_HOST_OS)" "freebsd"
EDCommon_LIBRARIES_DEPEND_UPON += -lcrypt
endif

# Mac OS X
ifneq ($(findstring darwin, $(GNUSTEP_HOST_OS)),)
  EDCommon_LDFLAGS += -seg1addr 0x35000000

  # Mac OS X 10.3
  ifneq ($(findstring darwin7, $(GNUSTEP_HOST_OS)),)
    EDCommon_LIBRARIES_DEPEND_UPON += -lresolv
  endif
  # Mac OS X 10.4
  ifneq ($(findstring darwin8, $(GNUSTEP_HOST_OS)),)
    EDCommon_LIBRARIES_DEPEND_UPON += -lresolv
  endif
endif


include Version

# This seems odd, but on Mach the dyld supports
# major/compatibility, thus you just need a single number.
# On UNIX things are different, hence we use the
# CURRENT_PROJECT_VERSION as the MAJOR_VERSION.

MAJOR_VERSION = $(CURRENT_PROJECT_VERSION)
#MINOR_VERSION = 0
#SUBMINOR_VERSION = 0


-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/framework.make

-include GNUmakefile.postamble

endif

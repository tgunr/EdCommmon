# EDCommon.framework
# GNUmakefile
#
# $Id: GNUmakefile,v 2.1 2003-09-04 14:35:12 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

# Install into the local root by default
GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_LOCAL_ROOT)

include $(GNUSTEP_MAKEFILES)/common.make

ifeq "$(OBJC_RUNTIME_LIB)" "gnu"
ADDITIONAL_OBJCFLAGS += -DGNU_RUNTIME
endif


FRAMEWORK_NAME = EDCommon


EDCommon_HEADER_FILES = \
EDCommon.h \
EDCommonDefines.h \
EDObjcRuntime.h \
osdep.h


EDCommon_OBJC_FILES = \
framework.m \
useful.m


EDCommon_LIBRARIES_DEPEND_UPON += -lcrypt


EDCommon_SUBPROJECTS = \
FoundationExtensions.subproj \
DataStructures.subproj


# AppKitExtensions.subproj and Widgets.subproj should be built
# ONLY if library-combo ends with something different than "nil"

ifneq "$(GUI_LIB)" "nil"
EDCommon_SUBPROJECTS += AppKitExtensions.subproj Widgets.subproj
else
ADDITIONAL_OBJCFLAGS += -DEDCOMMON_WOBUILD
endif

ifeq "$(OBJC_RUNTIME_LIB)" "gnu"
ADDITIONAL_OBJCFLAGS += -DGNU_RUNTIME
endif


-include Makefile.preamble

# This seems odd, but on Mach the dyld supports
# major/compatibility, thus you just need a single number.
# On UNIX things are different, hence we prefix our version
# with a "1".

MAJOR_VERSION = 1
MINOR_VERSION = $(CURRENT_PROJECT_VERSION)

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/framework.make

-include GNUmakefile.postamble

-include Makefile.postamble

endif

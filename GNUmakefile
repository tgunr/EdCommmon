# EDCommon.framework
# GNUmakefile
#
# $Id: GNUmakefile,v 1.2 2002-07-18 23:49:44 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

# Install into the local root by default
GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_LOCAL_ROOT)

include $(GNUSTEP_MAKEFILES)/common.make

# include config.mak


# The framework to be compiled
FRAMEWORK_NAME = EDCommon

EDCommon_HEADER_FILES = EDCommon.h EDCommonDefines.h EDObjcRuntime.h

EDCommon_OBJC_FILES = framework.m useful.m


# Widgets.subproj should be built ONLY if library-combo
# ends with something different than nil

EDCommon_SUBPROJECTS = FoundationExtensions.subproj DataStructures.subproj

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

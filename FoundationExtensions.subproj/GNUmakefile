# FoundationExtensions.subproj
# $Id: GNUmakefile,v 1.4 2002-07-18 23:49:46 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make


SUBPROJECT_NAME = FoundationExtensions.subproj

ADDITIONAL_INCLUDE_DIRS = -I..

ifeq "$(GUI_LIB)" "nil"
ADDITIONAL_OBJCFLAGS += -DEDCOMMON_WOBUILD
endif

ifeq "$(OBJC_RUNTIME_LIB)" "gnu"
ADDITIONAL_OBJCFLAGS += -DGNU_RUNTIME
endif


FoundationExtensions.subproj_OBJC_FILES = \
NSArray+Extensions.m            NSObject+Extensions.m \
NSAttributedString+Extensions.m NSProcessInfo+Extensions.m \
NSData+Extensions.m             NSScanner+Extensions.m \
NSDate+Extensions.m             NSSet+Extensions.m \
NSDictionary+Extensions.m       NSString+Extensions.m \
NSInvocation+Extensions.m

FoundationExtensions.subproj_HEADER_FILES = \
CollectionMapping.h             NSInvocation+Extensions.h \
NSArray+Extensions.h            NSObject+Extensions.h \
NSAttributedString+Extensions.h NSProcessInfo+Extensions.h \
NSData+Extensions.h             NSScanner+Extensions.h \
NSDate+Extensions.h             NSSet+Extensions.h \
NSDictionary+Extensions.h       NSString+Extensions.h


-include Makefile.preamble

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

-include Makefile.postamble

endif

# FoundationExtensions.subproj
# $Id: GNUmakefile,v 2.0 2002-08-16 18:12:48 erik Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_INCLUDE_DIRS = -I.. -I../DataStructures.subproj

ifeq "$(OBJC_RUNTIME_LIB)" "gnu"
ADDITIONAL_OBJCFLAGS += -DGNU_RUNTIME
endif

ifeq "$(GUI_LIB)" "nil"
ADDITIONAL_OBJCFLAGS += -DEDCOMMON_WOBUILD
endif


SUBPROJECT_NAME = FoundationExtensions.subproj


FoundationExtensions.subproj_HEADER_FILES = \
CollectionMapping.h                     NSDictionary+Extensions.h \
EDIPSocket.h                            NSFileHandle+Extensions.h \
EDSocket.h                              NSHost+Extensions.h \
EDStream.h                              NSInvocation+Extensions.h \
EDTCPSocket.h                           NSObject+Extensions.h \
EDUDPSocket.h                           NSProcessInfo+Extensions.h \
NSArray+Extensions.h                    NSScanner+Extensions.h \
NSAttributedString+Extensions.h         NSSet+Extensions.h \
NSData+Extensions.h                     NSString+Extensions.h \
NSDate+Extensions.h                     functions.h


FoundationExtensions.subproj_OBJC_FILES = \
EDIPSocket.m                            NSFileHandle+Extensions.m \
EDSocket.m                              NSHost+Extensions.m \
EDStream.m                              NSInvocation+Extensions.m \
EDTCPSocket.m                           NSObject+Extensions.m \
EDUDPSocket.m                           NSProcessInfo+Extensions.m \
NSArray+Extensions.m                    NSScanner+Extensions.m \
NSAttributedString+Extensions.m         NSSet+Extensions.m \
NSData+Extensions.m                     NSString+Extensions.m \
NSDate+Extensions.m                     functions.m \
NSDictionary+Extensions.m


FoundationExtensions.subproj_RESOURCE_FILES = MIME.plist


-include Makefile.preamble

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

-include Makefile.postamble

endif

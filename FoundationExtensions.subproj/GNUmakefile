# FoundationExtensions.subproj
# $Id: GNUmakefile,v 2.4 2003-10-21 16:26:40 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_INCLUDE_DIRS = -I.. -I../DataStructures.subproj


SUBPROJECT_NAME = FoundationExtensions.subproj


FoundationExtensions.subproj_HEADER_FILES = \
CollectionMapping.h             NSDate+Extensions.h \
EDIPSocket.h                    NSDictionary+Extensions.h \
EDSocket.h                      NSFileHandle+Extensions.h \
EDStream.h                      NSHost+Extensions.h \
EDStringWriter.h                NSInvocation+Extensions.h \
EDTCPSocket.h                   NSObject+Extensions.h \
EDTextWriter.h                  NSProcessInfo+Extensions.h \
EDUDPSocket.h                   NSScanner+Extensions.h \
NSArray+Extensions.h            NSSet+Extensions.h \
NSAttributedString+Extensions.h NSString+Extensions.h \
NSBundle+Extensions.h           deallocnotif.h \
NSData+Extensions.h             functions.h


FoundationExtensions.subproj_OBJC_FILES = \
EDIPSocket.m                    NSFileHandle+Extensions.m \
EDSocket.m                      NSHost+Extensions.m \
EDStream.m                      NSInvocation+Extensions.m \
EDStringWriter.m                NSObject+Extensions.m \
EDTCPSocket.m                   NSProcessInfo+Extensions.m \
EDUDPSocket.m                   NSScanner+Extensions.m \
NSArray+Extensions.m            NSSet+Extensions.m \
NSAttributedString+Extensions.m NSString+Extensions.m \
NSBundle+Extensions.m           NSData+Extensions.m \
NSDate+Extensions.m             deallocnotif.m \
NSDictionary+Extensions.m       functions.m


ifeq "$(OBJC_RUNTIME_LIB)" "gnu"
FoundationExtensions.subproj_OBJC_FILES += deallocnotif-gnu.m
else
FoundationExtensions.subproj_OBJC_FILES += deallocnotif-next.m
endif


FoundationExtensions.subproj_HAS_RESOURCE_BUNDLE = yes


FoundationExtensions.subproj_RESOURCE_FILES = MIME.plist


include ../GNUstepBuild


-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

endif

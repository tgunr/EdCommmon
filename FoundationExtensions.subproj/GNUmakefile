# FoundationExtensions.subproj
# $Id: GNUmakefile,v 1.1 2002-04-14 14:57:56 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make


SUBPROJECT_NAME = FoundationExtensions.subproj

ADDITIONAL_INCLUDE_DIRS = -I..


FoundationExtensions.subproj_OBJC_FILES = \
CollectionMapping.m             NSInvocation+Extensions.m \
NSArray+Extensions.m            NSObject+Extensions.m \
NSAttributedString+Extensions.m NSProcessInfo+Extensions.m \
NSData+Extensions.m             NSScanner+Extensions.m \
NSDate+Extensions.m             NSSet+Extensions.m \
NSDictionary+Extensions.m       NSString+Extensions.m

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

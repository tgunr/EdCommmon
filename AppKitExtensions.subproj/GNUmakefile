# AppKitExtensions.subproj
# $Id: GNUmakefile,v 2.1 2002-09-29 23:17:55 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_INCLUDE_DIRS = -I.. -I../FoundationExtensions.subproj

ifeq "$(OBJC_RUNTIME_LIB)" "gnu"
ADDITIONAL_OBJCFLAGS += -DGNU_RUNTIME
endif


SUBPROJECT_NAME = AppKitExtensions.subproj


AppKitExtensions.subproj_HEADER_FILES = \
EDApplication.h                         NSPasteboard+Extensions.h \
NSTableColumn+Extensions.h		EDKeyControlWindow.h \
NSApplication+Extensions.h              NSTableView+Extensions.h \
NSAttributedString+AppKitExtensions.h   NSWindow+Extensions.h \
NSMatrix+Extensions.h                   NSWorkspace+Extensions.h


AppKitExtensions.subproj_OBJC_FILES = \
EDApplication.m                         NSPasteboard+Extensions.m \
NSTableColumn+Extensions.m		EDKeyControlWindow.m \
NSApplication+Extensions.m              NSTableView+Extensions.m \
NSAttributedString+AppKitExtensions.m   NSWindow+Extensions.m \
NSMatrix+Extensions.m                   NSWorkspace+Extensions.m


AppKitExtensions.subproj_HAS_RESOURCE_BUNDLE = yes


AppKitExtensions.subproj_RESOURCE_FILES = arrows.tiff


-include Makefile.preamble

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

-include Makefile.postamble

endif

# AppKitExtensions.subproj
# $Id: GNUmakefile,v 1.2 2002-07-18 23:49:45 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make


SUBPROJECT_NAME = AppKitExtensions.subproj

ADDITIONAL_INCLUDE_DIRS = -I.. -I../FoundationExtensions.subproj

ifeq "$(OBJC_RUNTIME_LIB)" "gnu"
ADDITIONAL_OBJCFLAGS += -DGNU_RUNTIME
endif


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


AppKitExtensions.subproj_RESOURCE_FILES = arrows.tiff


-include Makefile.preamble

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

-include Makefile.postamble

endif

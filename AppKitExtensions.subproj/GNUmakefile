# AppKitExtensions.subproj
# $Id: GNUmakefile,v 2.2 2003-10-21 16:26:39 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_INCLUDE_DIRS = -I.. -I../FoundationExtensions.subproj


SUBPROJECT_NAME = AppKitExtensions.subproj


AppKitExtensions.subproj_HEADER_FILES = \
EDApplication.h                         NSPasteboard+Extensions.h \
EDKeyControlWindow.h                    NSTableColumn+Extensions.h \
EDToolbarDefinition.h                   NSTableView+Extensions.h \
NSApplication+Extensions.h              NSWindow+Extensions.h \
NSAttributedString+AppKitExtensions.h   NSWorkspace+Extensions.h \
NSMatrix+Extensions.h \


AppKitExtensions.subproj_OBJC_FILES = \
EDApplication.m                         NSPasteboard+Extensions.m \
EDKeyControlWindow.m                    NSTableColumn+Extensions.m \
EDToolbarDefinition.m                   NSTableView+Extensions.m \
NSApplication+Extensions.m              NSWindow+Extensions.m \
NSAttributedString+AppKitExtensions.m   NSWorkspace+Extensions.m \
NSMatrix+Extensions.m \


AppKitExtensions.subproj_HAS_RESOURCE_BUNDLE = yes


AppKitExtensions.subproj_RESOURCE_FILES = arrows.tiff


include ../GNUstepBuild


-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

endif

# Widgets.subproj
# $Id: GNUmakefile,v 2.1 2003-10-21 16:26:42 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_INCLUDE_DIRS = -I..


SUBPROJECT_NAME = Widgets.subproj


Widgets.subproj_HEADER_FILES = \
EDActivityIndicator.h   EDObjectWell.h          EDTVScrollView.h \
EDCanvas.h              EDSwapView.h            EDTableView.h


Widgets.subproj_OBJC_FILES = \
EDActivityIndicator.m   EDObjectWell.m          EDTVScrollView.m \
EDCanvas.m              EDSwapView.m            EDTableView.m


include ../GNUstepBuild


-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

endif

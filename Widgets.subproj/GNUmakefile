# Widgets.subproj
# $Id: GNUmakefile,v 1.1 2002-04-14 14:57:58 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make


SUBPROJECT_NAME = Widgets.subproj

ADDITIONAL_INCLUDE_DIRS = -I..


Widgets.subproj_HEADER_FILES = \
EDActivityIndicator.h   EDObjectWell.h          EDTVScrollView.h \
EDCanvas.h              EDSwapView.h            EDTableView.h

Widgets.subproj_OBJC_FILES = \
EDActivityIndicator.m   EDObjectWell.m          EDTVScrollView.m \
EDCanvas.m              EDSwapView.m            EDTableView.m


-include Makefile.preamble

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

-include Makefile.postamble

endif

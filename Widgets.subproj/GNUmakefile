# Widgets.subproj
# $Id: GNUmakefile,v 2.0 2002-08-16 18:12:50 erik Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make

ifeq "$(OBJC_RUNTIME_LIB)" "gnu"
ADDITIONAL_OBJCFLAGS += -DGNU_RUNTIME
endif

ADDITIONAL_INCLUDE_DIRS = -I..


SUBPROJECT_NAME = Widgets.subproj


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

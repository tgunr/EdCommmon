# Testing.subproj
#
# NOTE: In order for this to run, you need the excellent OCUnit testing framework
# from SEN:TE available at http://www.sente.ch/software/ocunit/
#
# $Id: GNUmakefile,v 1.1 2003-05-28 01:19:21 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

# Install into the user root by default
GNUSTEP_INSTALLATION_DIR = $(GNUSTEP_USER_ROOT)

include $(GNUSTEP_MAKEFILES)/common.make


ADDITIONAL_INCLUDE_DIRS = \
-I.. \
-I../AppKitExtensions.subproj \
-I../DataStructures.subproj \
-I../FoundationExtensions.subproj \
-I../Widgets.subproj


# The tools to be compiled
TOOL_NAME = EDCommonTests


EDCommonTests_OBJC_FILES = \
EDXMLAttributeTests.m           EDXMLNamedNodeMapTests.m \
EDXMLDOMTagProcessorTests.m     EDXMLTextTests.m \
EDXMLDocumentFragmentTests.m    EDXMLTreeWalkerTests.m \
EDXMLDocumentTests.m            testmain.m \
EDXMLElementTests.m


EDCommonTests_OBJC_LIBS = -lEDCommon -lcrypt -lSenFoundation -lSenTestingKit
ifneq "$(GUI_LIB)" "nil"
EDCommonTests_OBJC_LIBS += -lgnustep-gui
endif

ifeq "$(OBJC_RUNTIME_LIB)" "gnu"
ADDITIONAL_OBJCFLAGS += -DGNU_RUNTIME
endif


-include Makefile.preamble

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/tool.make

-include GNUmakefile.postamble

-include Makefile.postamble

endif

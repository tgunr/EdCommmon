# Testing.subproj
#
# NOTE: In order for this to run, you need the excellent OCUnit testing framework
# from SEN:TE available at http://www.sente.ch/software/ocunit/
#
# $Id: GNUmakefile,v 1.3 2003-10-21 16:26:41 znek Exp $


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


EDCommonTests_OBJC_LIBS = -lEDCommon -lSenFoundation -lSenTestingKit
ifneq "$(GUI_LIB)" "nil"
EDCommonTests_OBJC_LIBS += -lgnustep-gui
endif


EDCommonTests_HAS_RESOURCE_BUNDLE = yes


EDCommonTests_RESOURCE_FILES = Sample.xml SampleWithNamespaces.xml


include ../GNUstepBuild


-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/tool.make

-include GNUmakefile.postamble

endif

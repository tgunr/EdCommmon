# DataStructures.subproj
# $Id: GNUmakefile,v 2.2 2003-01-03 16:08:59 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_INCLUDE_DIRS = -I.. -I../FoundationExtensions.subproj

ifeq "$(OBJC_RUNTIME_LIB)" "gnu"
ADDITIONAL_OBJCFLAGS += -DGNU_RUNTIME
endif


SUBPROJECT_NAME = DataStructures.subproj


DataStructures.subproj_HEADER_FILES = \
EDAOMTagProcessor.h             EDNumberSet.h \
EDBitmapCharset.h               EDObjectPair.h \
EDIRCObject.h                   EDObjectReference.h \
EDLRUCache.h                    EDRange.h \
EDLightWeightLock.h             EDRedBlackTree+Private.h \
EDMLParser.h                    EDRedBlackTree.h \
EDMLTagProcessorProtocol.h      EDSparseClusterArray.h \
EDMLToken.h                     EDStack.h \
EDMutableObjectPair.h           EDStringScanner.h


DataStructures.subproj_OBJC_FILES = \
EDBitmapCharset.m         EDMLToken.m               EDRedBlackTree.m \
EDIRCObject.m             EDNumberSet.m             EDSparseClusterArray.m \
EDLRUCache.m              EDObjectPair.m            EDStack.m \
EDAOMTagProcessor.m 	  EDObjectReference.m       EDStringScanner.m \
EDMLParser.m              EDRange.m                 EDMutableObjectPair.m


DataStructures.subproj_HAS_RESOURCE_BUNDLE = yes


DataStructures.subproj_RESOURCE_FILES = XMLEntities.plist


-include Makefile.preamble

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

-include Makefile.postamble

endif

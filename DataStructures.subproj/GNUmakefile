# DataStructures.subproj
# $Id: GNUmakefile,v 2.1 2002-08-17 17:40:03 znek Exp $


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


-include Makefile.preamble

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

-include Makefile.postamble

endif

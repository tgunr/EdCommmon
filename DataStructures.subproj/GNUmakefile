# DataStructures.subproj
# $Id: GNUmakefile,v 2.0 2002-08-16 18:12:46 erik Exp $


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
EDBitmapCharset.h                       EDObjectPair.h \
EDIRCObject.h                           EDObjectReference.h \
EDLRUCache.h                            EDRange.h \
EDLightWeightLock.h                     EDRedBlackTree+Private.h \
EDAOMTagProcessor.h               	EDRedBlackTree.h \
EDMLParser.h                            EDSparseClusterArray.h \
EDMLTagProcessorProtocol.h              EDStack.h \
EDStringScanner.h                       EDNumberSet.h \
EDMUtableObjectPair.h


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

# DataStructures.subproj
# $Id: GNUmakefile,v 1.1 2002-04-14 14:57:55 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make


SUBPROJECT_NAME = DataStructures.subproj

ADDITIONAL_INCLUDE_DIRS = -I.. -I../FoundationExtensions.subproj


DataStructures.subproj_OBJC_FILES = \
EDBitmapCharset.m       EDNumberSet.m           EDSparseClusterArray.m \
EDIRCObject.m           EDObjectPair.m          EDStack.m \
EDLRUCache.m            EDObjectReference.m     EDStringScanner.m \
EDMLParser.m            EDRange.m \
EDMLToken.m             EDRedBlackTree.m

DataStructures.subproj_HEADER_FILES = \
EDBitmapCharset.h               EDObjectReference.h \
EDIRCObject.h                   EDRange.h \
EDLRUCache.h                    EDRedBlackTree+Private.h \
EDLightWeightLock.h             EDRedBlackTree.h \
EDMLParser.h                    EDSparseClusterArray.h \
EDMLToken.h                     EDStack.h \
EDNumberSet.h                   EDStringScanner.h \
EDObjectPair.h


-include Makefile.preamble

-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

-include Makefile.postamble

endif

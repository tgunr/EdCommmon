# DataStructures.subproj
# $Id: GNUmakefile,v 2.5 2003-10-21 16:26:39 znek Exp $


ifeq "$(GNUSTEP_SYSTEM_ROOT)" ""
  include Makefile
else

include $(GNUSTEP_MAKEFILES)/common.make

ADDITIONAL_INCLUDE_DIRS = -I.. -I../FoundationExtensions.subproj


SUBPROJECT_NAME = DataStructures.subproj


DataStructures.subproj_HEADER_FILES = \
EDAOMTagProcessor.h             EDSparseClusterArray.h \
EDBitmapCharset.h               EDStack.h \
EDIRCObject.h                   EDStringScanner.h \
EDLRUCache.h                    EDXMLAttribute.h \
EDLightWeightLock.h             EDXMLCharacterData.h \
EDMLParser.h                    EDXMLDOMTagProcessor.h \
EDMLTagProcessorProtocol.h      EDXMLDocument.h \
EDMLToken.h                     EDXMLDocumentFragment.h \
EDMutableObjectPair.h           EDXMLElement.h \
EDNumberSet.h                   EDXMLNamedNodeMap.h \
EDObjectPair.h \
EDObjectReference.h             EDXMLNode.h \
EDRange.h                       EDXMLNodeList.h \
EDXMLText.h \
EDSortedArray.h                 EDXMLTreeWalker.h


DataStructures.subproj_OBJC_FILES = \
EDAOMTagProcessor.m     EDObjectReference.m     EDXMLDocument.m \
EDBitmapCharset.m       EDRange.m               EDXMLDocumentFragment.m \
EDIRCObject.m           EDSortedArray.m         EDXMLElement.m \
EDLRUCache.m            EDSparseClusterArray.m  EDXMLNamedNodeMap.m \
EDMLParser.m            EDStack.m               EDXMLNode.m \
EDMLToken.m             EDStringScanner.m       EDXMLNodeList.m \
EDMutableObjectPair.m   EDXMLAttribute.m        EDXMLText.m \
EDNumberSet.m           EDXMLCharacterData.m    EDXMLTreeWalker.m \
EDObjectPair.m          EDXMLDOMTagProcessor.m


DataStructures.subproj_HAS_RESOURCE_BUNDLE = yes


DataStructures.subproj_RESOURCE_FILES = XMLEntities.plist


include ../GNUstepBuild


-include GNUmakefile.preamble

include $(GNUSTEP_MAKEFILES)/subproject.make

-include GNUmakefile.postamble

endif

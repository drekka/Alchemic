//
//  ALCMacros.h
//  Alchemic
//
//  Created by Derek Clarkson on 25/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#define AcIgnoreSelectorWarnings(code) \
_Pragma ("clang diagnostic push") \
_Pragma ("clang diagnostic ignored \"-Wselector\"") \
_Pragma ("clang diagnostic ignored \"-Wundeclared-selector\"") \
code \
_Pragma ("clang diagnostic pop")


//
//  ALCIsExternal.h
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#define ALCFlagMacroHeader(name) \
@interface ALCIs ## name : NSObject \
+ (instancetype) macro; \
@end

ALCFlagMacroHeader(Reference)
ALCFlagMacroHeader(Weak)
ALCFlagMacroHeader(Primary)
ALCFlagMacroHeader(Template)
ALCFlagMacroHeader(Nillable)
ALCFlagMacroHeader(Transient)

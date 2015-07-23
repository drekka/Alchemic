//
//  ALCMethodArgMacroProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#include "ALCMacroProcessor.h"
@protocol ALCMacro;

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractMacroProcessor : NSObject<ALCMacroProcessor>

-(void) raiseUnexpectedMacroError:(id<ALCMacro>) macro;

@end

NS_ASSUME_NONNULL_END

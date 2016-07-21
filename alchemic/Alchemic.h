//
//  Alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "AlchemicAware.h"
#import "AlchemicConfig.h"
#import "ALCConstantInjectors.h"
#import "ALCContext.h"
#import "ALCDefs.h"
#import "ALCException.h"
#import "ALCFactoryName.h"
#import "ALCFlagMacros.h"
#import "ALCMacros.h"
#import "ALCMethodArgumentDependency.h"
#import "ALCModelSearchCriteria.h"

//! Project version number for alchemic.
FOUNDATION_EXPORT double alchemicVersionNumber;

//! Project version string for alchemic.
FOUNDATION_EXPORT const unsigned char alchemicVersionString[];

/**
 Base class for the Alchemic injection framework.
 */
@interface Alchemic : NSObject

/**
 Returns the main context.
 
 @return The current instance of ALCContext.
 */
+(id<ALCContext>) mainContext;

@end

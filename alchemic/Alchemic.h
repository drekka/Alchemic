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
#import "ALCClassObjectFactory.h"
#import "ALCCloudKeyValueStore.h"
#import "ALCCloudKeyValueStoreAspect.h"
#import "ALCConstantValueSource.h"
#import "ALCContext.h"
#import "ALCDefs.h"
#import "ALCException.h"
#import "ALCFactoryName.h"
#import "ALCFlagMacros.h"
#import "ALCMacros.h"
#import "ALCMethodArgumentDependency.h"
#import "ALCModelSearchCriteria.h"
#import "ALCObjectFactory.h"
#import "ALCResolveAspect.h"
#import "ALCStringMacros.h"
#import "ALCUserDefaults.h"
#import "ALCUserDefaultsAspect.h"
#import "ALCValueStore.h"

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
+(id<ALCContext>) mainContext __attribute__((const));

@end

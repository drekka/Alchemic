//
//  Alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/AlchemicAware.h>
#import <Alchemic/AlchemicConfig.h>
#import <Alchemic/ALCConstantInjectors.h>
#import <Alchemic/ALCContext.h>
#import <Alchemic/ALCDefs.h>
#import <Alchemic/ALCException.h>
#import <Alchemic/ALCFactoryName.h>
#import <Alchemic/ALCFlagMacros.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCMethodArgumentDependency.h>
#import <Alchemic/ALCModelSearchCriteria.h>
#import <Alchemic/ALCResolveAspect.h>

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

//
//  Alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

//! Project version number for alchemic.
FOUNDATION_EXPORT double alchemicVersionNumber;

//! Project version string for alchemic.
FOUNDATION_EXPORT const unsigned char alchemicVersionString[];

FOUNDATION_EXPORT NSString *AlchemicDidCreateObject;
FOUNDATION_EXPORT NSString *AlchemicDidCreateObjectUserInfoObject;
FOUNDATION_EXPORT NSString *AlchemicDidFinishStarting;

#import <Alchemic/ALCDefs.h>
#import <Alchemic/ALCContext.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCObjectFactory.h>
#import <Alchemic/ALCInstantiator.h>
#import <Alchemic/ALCResolvable.h>
#import <Alchemic/ALCConstants.h>
#import <Alchemic/ALCConstant.h>
#import <Alchemic/ALCDependency.h>
#import <Alchemic/ALCResolvable.h>
#import <Alchemic/ALCArgument.h>
#import <Alchemic/ALCException.h>
#import <Alchemic/ALCModelSearchCriteria.h>

@interface Alchemic : NSObject

/**
 Returns the main context.

 @return The current instance of ALCContext.
 */
+(id<ALCContext>) mainContext;

@end

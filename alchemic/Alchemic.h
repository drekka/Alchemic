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

#import <Alchemic/ALCConfig.h>
#import <Alchemic/ALCContextImpl.h>
#import <Alchemic/ALCDefs.h>
#import <Alchemic/ALCException.h>
#import <Alchemic/AlchemicAware.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCResolvable.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCDependency.h>
#import <Alchemic/ALCConstant.h>
#import <Alchemic/ALCModelDependency.h>
#import <Alchemic/ALCConstants.h>
#import <Alchemic/ALCArgument.h>
#import <Alchemic/ALCAbstractConstantValue.h>
#import <Alchemic/ALCInstantiator.h>
#import <Alchemic/ALCObjectFactory.h>
#import <Alchemic/ALCFactoryName.h>
#import <Alchemic/ALCIsReference.h>
#import <Alchemic/ALCIsFactory.h>
#import <Alchemic/ALCIsPrimary.h>
#import <Alchemic/ALCAbstractObjectFactory.h>
#import <Alchemic/ALCClassObjectFactory.h>
#import <Alchemic/ALCClassObjectFactoryInitializer.h>
#import <Alchemic/ALCDependencyRef.h>
#import <Alchemic/ALCInstantiation.h>
#import <Alchemic/ALCMethodObjectFactory.h>
#import <Alchemic/ALCObjectFactoryType.h>
#import <Alchemic/ALCObjectFactoryTypeFactory.h>
#import <Alchemic/ALCObjectFactoryTypeReference.h>
#import <Alchemic/ALCObjectFactoryTypeSingleton.h>
#import <Alchemic/ALCModelImpl.h>
#import <Alchemic/ALCModel.h>
#import <Alchemic/ALCModelSearchCriteria.h>
#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCRuntimeScanner.h>
#import <Alchemic/ALCTypeData.h>
#import <Alchemic/NSArray+Alchemic.h>
#import <Alchemic/NSBundle+Alchemic.h>
#import <Alchemic/NSObject+Alchemic.h>
#import <Alchemic/NSSet+Alchemic.h>

@interface Alchemic : NSObject

/**
 Returns the main context.

 @return The current instance of ALCContext.
 */
+(id<ALCContext>) mainContext;

@end

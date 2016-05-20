//
//  Alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 26/01/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/ALCAbstractConstantInjector.h>
#import <Alchemic/ALCAbstractDependency.h>
#import <Alchemic/ALCAbstractObjectFactory.h>
#import <Alchemic/ALCClassObjectFactory.h>
#import <Alchemic/ALCClassObjectFactoryInitializer.h>
#import <Alchemic/ALCClassProcessor.h>
#import <Alchemic/ALCConfig.h>
//#import <Alchemic/ALCConfigClassProcessor.h>
#import <Alchemic/ALCConstant.h>
#import <Alchemic/ALCConstantInjectors.h>
#import <Alchemic/ALCContextImpl.h>
#import <Alchemic/ALCDefs.h>
#import <Alchemic/ALCDependency.h>
#import <Alchemic/AlchemicException.h>
#import <Alchemic/ALCFactoryName.h>
#import <Alchemic/AlchemicAware.h>
#import <Alchemic/ALCInjector.h>
#import <Alchemic/ALCInstantiation.h>
#import <Alchemic/ALCInstantiator.h>
#import <Alchemic/ALCInternalMacros.h>
#import <Alchemic/ALCIsFactory.h>
#import <Alchemic/ALCIsPrimary.h>
#import <Alchemic/ALCIsReference.h>
#import <Alchemic/ALCMacros.h>
#import <Alchemic/ALCMethodArgument.h>
#import <Alchemic/ALCMethodObjectFactory.h>
#import <Alchemic/ALCModel.h>
#import <Alchemic/ALCModelClassProcessor.h>
#import <Alchemic/ALCModelImpl.h>
#import <Alchemic/ALCModelObjectInjector.h>
#import <Alchemic/ALCModelSearchCriteria.h>
#import <Alchemic/ALCObjectFactory.h>
#import <Alchemic/ALCObjectFactoryType.h>
#import <Alchemic/ALCObjectFactoryTypeFactory.h>
#import <Alchemic/ALCObjectFactoryTypeReference.h>
#import <Alchemic/ALCObjectFactoryTypeSingleton.h>
#import <Alchemic/ALCResolvable.h>
#import <Alchemic/ALCResourceLocatorClassProcessor.h>
#import <Alchemic/ALCRuntime.h>
#import <Alchemic/ALCTypeData.h>
#import <Alchemic/ALCVariableDependency.h>
#import <Alchemic/NSArray+Alchemic.h>
#import <Alchemic/NSBundle+Alchemic.h>
#import <Alchemic/NSObject+Alchemic.h>
#import <Alchemic/NSSet+Alchemic.h>

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

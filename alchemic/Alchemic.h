//
//  alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 11/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import <Alchemic/ALCMacros.h>
#import "ALCInternal.h"
#import "ALCClassBuilder.h"
#import "ALCContext.h"
#import "ALCClassMatcher.h"
#import "ALCProtocolMatcher.h"
#import "ALCNameMatcher.h"
#import "ALCReturnType.h"
#import "ALCIsFactory.h"
#import "ALCMethodSelector.h"
#import "ALCIntoVariable.h"
#import "ALCAsName.h"
#import "ALCIsPrimary.h"
#import "ALCAbstractClass.h"
#import "ALCAbstractInitStrategy.h"
#import "ALCArrayValueResolver.h"
#import "ALCBundleResourceLocator.h"
#import "ALCClassProcessor.h"
#import "ALCClassWithProtocolClassProcessor.h"
#import "ALCDefaultValueResolverManager.h"
#import "ALCFileContentsResourceLocator.h"
#import "ALCInitStrategyInjector.h"
#import "ALCMethodBuilder.h"
#import "ALCModelClassProcessor.h"
#import "ALCNSObjectInitStrategy.h"
#import "ALCPlistResourceLocator.h"
#import "ALCPrimaryObjectDependencyPostProcessor.h"
#import "ALCResourceLocator.h"
#import "ALCRuntime.h"
#import "ALCSimpleObjectFactory.h"
#import "ALCSimpleValueResolver.h"
#import "ALCType.h"
#import "ALCUIViewControllerInitWithCoderStrategy.h"
#import "ALCUIViewControllerInitWithFrameStrategy.h"
#import "ALCVariableDependency.h"
#import "AlchemicAware.h"
#import "NSDictionary+ALCModel.h"

@interface Alchemic : NSObject

/**
 Returns the main context.
 @return The current instance of ALCContext.
 */
+(ALCContext *) mainContext;

@end

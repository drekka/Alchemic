//
//  ALCObjectResolverFactory.h
//  alchemic
//
//  Created by Derek Clarkson on 17/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCCandidateValueResolver.h"
#import "ALCModelObject.h"

/**
 A factory for find the particular object resolver for a dependency.
 */
@protocol ALCCandidateValueResolverFactory <NSObject>

-(id<ALCCandidateValueResolver>) resolverForDependency:(id<ALCModelObject>) dependency;

@end

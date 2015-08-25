//
//  ALCClassInstantiator.m
//  alchemic
//
//  Created by Derek Clarkson on 24/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCClassInstantiator.h"
#import <StoryTeller/StoryTeller.h>

@implementation ALCClassInstantiator {
    Class _objectType;
}

-(instancetype) init {
    return nil;
}

-(instancetype) initWithObjectType:(Class) objectType {
    self = [super init];
    if (self) {
        _objectType = objectType;
    }
    return self;
}

-(BOOL) available {
    return YES;
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                  dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack{}

-(NSString *)builderName {
    return NSStringFromClass(_objectType);
}

/**
 Injects an object with dependencies.

 @param object The object to be injected.
 */

-(id) instantiateWithArguments:(NSArray *) arguments {
    STLog(_objectType, @"Creating a %@", NSStringFromClass(_objectType));
    id value = [[_objectType alloc] init];
    return value;
}

@end

//
//  ALCInitializerInstantiator.m
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCInitializerInstantiator.h"
#import "ALCBuilder.h"
#import "ALCClassBuilder.h"
#import "NSObject+Builder.h"
#import "ALCRuntime.h"

@implementation ALCInitializerInstantiator {
    SEL _initializer;
    Class _class;
}

hideInitializerImpl(init)

-(instancetype) initWithClass:(Class) aClass
                  initializer:(SEL) initializer {
    self = [super init];
    if (self) {
        _initializer = initializer;
        _class = aClass;
    }
    return self;
}

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                              dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack {
    [super resolveDependenciesWithPostProcessors:postProcessors dependencyStack:dependencyStack];
    [ALCRuntime validateClass:_class selector:_initializer];
}

-(NSString *)builderName {
    return [NSString stringWithFormat:@"%@ %@", NSStringFromClass(_class), NSStringFromSelector(_initializer)];
}

-(id) instantiateWithClassBuilder:(ALCClassBuilder *) classBuilder arguments:(NSArray *) arguments {
    STLog(_class, @"Instantiating a %@ using %@", NSStringFromClass(_class), self);
    id object = [[_class alloc] invokeSelector:_initializer arguments:arguments];
    [classBuilder injectDependencies:object];
    return object;
}

-(NSString *)attributeText {
    return [NSString stringWithFormat:@", using initializer [%@ %@]", NSStringFromClass(_class), NSStringFromSelector(_initializer)];
}

@end

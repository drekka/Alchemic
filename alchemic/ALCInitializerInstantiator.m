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
#import "NSObject+Builder.h"
#import "ALCRuntime.h"

@implementation ALCInitializerInstantiator {
    id<ALCBuilder> _classBuilder;
    SEL _initializerSelector;
}

-(instancetype) init {
    return nil;
}

-(instancetype) initWithClassBuilder:(id<ALCBuilder>) classBuilder
                         initializer:(SEL) initializerSelector {
    self = [super init];
    if (self) {
        _classBuilder = classBuilder;
        _initializerSelector = initializerSelector;
    }
    return self;
}

-(BOOL) available {
    return _classBuilder.available;
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                  dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack{
    [ALCRuntime validateClass:_classBuilder.valueClass
                     selector:_initializerSelector];
    STLog(_classBuilder.valueClass, @"Resolving parent %@", _classBuilder);
    [_classBuilder resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];
}

-(NSString *)builderName {
    return [NSString stringWithFormat:@"%@ %@", NSStringFromClass(_classBuilder.valueClass), NSStringFromSelector(_initializerSelector)];
}

-(id) instantiateWithArguments:(NSArray *) arguments {
    STLog(self, @"Instantiating a %@ using %@", NSStringFromClass(_classBuilder.valueClass), self);
    return [[_classBuilder.valueClass alloc] invokeSelector:_initializerSelector arguments:arguments];
}

-(NSString *)attributeText {
    return [NSString stringWithFormat:@", using initializer [%@ %@]", NSStringFromClass(_classBuilder.valueClass), NSStringFromSelector(_initializerSelector)];
}

@end

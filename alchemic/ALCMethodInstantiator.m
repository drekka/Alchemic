//
//  ALCMethodInstantiator.m
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCMethodInstantiator.h"
#import "ALCBuilder.h"
#import "NSObject+Builder.h"
#import "ALCRuntime.h"

@implementation ALCMethodInstantiator {
    id<ALCBuilder> _classBuilder;
    SEL _methodSelector;
}

-(instancetype) init {
    return nil;
}

-(instancetype) initWithClassBuilder:(id<ALCBuilder>) classBuilder
                            selector:(SEL) methodSelector {
    self = [super init];
    if (self) {
        _classBuilder = classBuilder;
        _methodSelector = methodSelector;
    }
    return self;
}

-(BOOL) available {
    return _classBuilder.available;
}

-(void) resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                  dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack{
    [ALCRuntime validateClass:_classBuilder.valueClass
                     selector:_methodSelector];
    [_classBuilder resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];
}

-(NSString *)builderName {
    return [NSString stringWithFormat:@"%@ %@", NSStringFromClass(_classBuilder.valueClass), NSStringFromSelector(_methodSelector)];
}

-(id) instantiateWithArguments:(NSArray *) arguments {
    STLog(_classBuilder.valueClass, @"Retrieving method's parent object ...");
    id factoryObject = _classBuilder.value;
    return [factoryObject invokeSelector:_methodSelector arguments:arguments];
}

@end

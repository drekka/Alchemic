//
//  ALCMethodInstantiator.m
//  alchemic
//
//  Created by Derek Clarkson on 25/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCMethodInstantiator.h"
#import "ALCClassBuilder.h"
#import "NSObject+Builder.h"
#import "ALCRuntime.h"
#import "ALCAlchemic.h"
#import "ALCContext.h"

@implementation ALCMethodInstantiator {
    SEL _selector;
    Class _returnType;
    ALCClassBuilder *_returnTypeBuilder;
    Class _class;
}

hideInitializerImpl(init)

-(instancetype) initWithClass:(Class) aClass
                   returnType:(Class) returnType
                     selector:(SEL) selector {
    self = [super init];
    if (self) {
        _class = aClass;
        _returnType = returnType;
        _selector = selector;
    }
    return self;
}

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                  dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack {

    // Go find the class builder for the return type and get it to tell us when it's available.
    STLog(_returnType, @"Searching for class builder for a %@", NSStringFromClass(_returnType));
    _returnTypeBuilder = [[ALCAlchemic mainContext] builderForClass:_returnType];
    [self watchResolvable:_returnTypeBuilder];
    [_returnTypeBuilder resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];

    // Verify the selector.
    [ALCRuntime validateClass:_class selector:_selector];
}

-(id) instantiateWithClassBuilder:(id<ALCBuilder>) classBuilder arguments:(NSArray *) arguments {
    STLog(_returnType, @"Retrieving method's parent object ...");
    id factoryObject = classBuilder.value;
    id object = [factoryObject invokeSelector:_selector arguments:arguments];
    if (_returnTypeBuilder != nil) {
        [_returnTypeBuilder injectDependencies:object];
    }
    return object;
}

-(NSString *)builderName {
    return [NSString stringWithFormat:@"%@ %@", NSStringFromClass(_class), NSStringFromSelector(_selector)];
}

-(NSString *)attributeText {
    return [NSString stringWithFormat:@", using method [%@ %@]", NSStringFromClass(_class), NSStringFromSelector(_selector)];
}

@end

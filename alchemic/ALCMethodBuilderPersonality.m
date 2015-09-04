//
//  ALCBuilderPersonality.m
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import <StoryTeller/StoryTeller.h>

#import "ALCMethodBuilderPersonality.h"
#import "ALCBuilder.h"
#import "ALCMacroProcessor.h"
#import "NSObject+Builder.h"
#import "ALCRuntime.h"
#import "ALCContext.h"
#import "Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodBuilderPersonality {
    SEL _selector;
    Class _returnType;
    ALCBuilder *_returnTypeBuilder;
}

hideInitializerImpl(initClassBuilder:(ALCBuilder *) classBuilder)

-(instancetype) initWithClassBuilder:(ALCBuilder *) classBuilder
                            selector:(SEL) selector
                          returnType:(Class) returnType {
    self = [super initWithClassBuilder:classBuilder];
    if (self) {
        _selector = selector;
        _returnType = returnType;
    }
    return self;
}

-(ALCPersonalityType)type {
    return ALCPersonalityTypeMethod;
}

-(NSString *) builderName {
    return [NSString stringWithFormat:@"%@ %@", NSStringFromClass(self.builder.valueClass), NSStringFromSelector(_selector)];
}

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                              dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack {

    [super resolveDependenciesWithPostProcessors:postProcessors dependencyStack:dependencyStack];

    [ALCRuntime validateClass:self.classBuilder.valueClass selector:_selector];

    // Go find the class builder for the return type and get it to tell us when it's available.
    ALCBuilder *builder = self.builder;
    STLog(builder.valueClass, @"Searching for class builder for return type %@", NSStringFromClass(builder.valueClass));
    _returnTypeBuilder = [[ALCAlchemic mainContext] builderForClass:builder.valueClass];
    if (_returnTypeBuilder != nil) {
        STLog(builder.valueClass, @"Watching return type builder");
        [builder watchResolvable:_returnTypeBuilder];
        [_returnTypeBuilder resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];
    }
}

-(id) invokeWithArgs:(NSArray<id> *) arguments {
    STLog(_returnType, @"Instantiating a %@ using %@", NSStringFromClass(_returnType), self);
    id factoryObject = self.classBuilder.value;
    id object = [factoryObject invokeSelector:_selector arguments:arguments];
    [self injectDependencies:object];
    return object;
}

-(BOOL)canInjectDependencies {
    return _returnTypeBuilder.available;
}

-(void)injectDependencies:(id)object {
    if (_returnTypeBuilder != nil) {
        [_returnTypeBuilder injectDependencies:object];
    }
}

-(NSString *)attributeText {
    return [NSString stringWithFormat:@", using method [%@]", [self builderName]];
}

@end

NS_ASSUME_NONNULL_END

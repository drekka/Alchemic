//
//  ALCInitializerBuilderPersonality.m
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import <StoryTeller/StoryTeller.h>

#import "ALCInitializerBuilderPersonality.h"
#import "ALCBuilder.h"
#import "ALCMacroProcessor.h"
#import "NSObject+Builder.h"
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCInitializerBuilderPersonality {
    SEL _initializer;
}

hideInitializerImpl(initWithClassBuilder:(ALCBuilder *) classBuilder)

-(instancetype) initWithClassBuilder:(ALCBuilder *) classBuilder
                         initializer:(SEL) initializer {
    self = [super initWithClassBuilder:classBuilder];
    if (self) {
        _initializer = initializer;
    }
    return self;
}

-(ALCPersonalityType)type {
    return ALCPersonalityTypeInitializer;
}

-(NSString *) builderName {
    return [NSString stringWithFormat:@"%@ %@", NSStringFromClass(self.builder.valueClass), NSStringFromSelector(_initializer)];
}

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors
                              dependencyStack:(NSMutableArray<id<ALCResolvable>> *) dependencyStack {
    [super resolveDependenciesWithPostProcessors:postProcessors dependencyStack:dependencyStack];
    [ALCRuntime validateClass:self.builder.valueClass selector:_initializer];
}

-(id) invokeWithArgs:(NSArray<id> *) arguments {
    ALCBuilder *builder = self.builder;
    STLog(builder.valueClass, @"Instantiating a %@ using %@", NSStringFromClass(builder.valueClass), self);
    id object = [[builder.valueClass alloc] invokeSelector:_initializer arguments:arguments];
    [self injectDependencies:object];
    return object;
}

-(BOOL)canInjectDependencies {
    return self.classBuilder.available;
}

-(void)injectDependencies:(id)object {
    [self.classBuilder injectDependencies:object];
}

-(NSString *)attributeText {
    return [NSString stringWithFormat:@", using initializer [%@]", [self builderName]];
}

@end

NS_ASSUME_NONNULL_END

//
//  ALCInitializerBuilderType.m
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import <StoryTeller/StoryTeller.h>

#import "ALCInitializerBuilderType.h"
#import "ALCBuilder.h"
#import "ALCMacroProcessor.h"
#import "NSObject+Builder.h"
#import "ALCRuntime.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCInitializerBuilderType {
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

-(ALCBuilderType)type {
    return ALCBuilderTypeInitializer;
}

-(NSString *) builderName {
    return [NSString stringWithFormat:@"%@ %@", NSStringFromClass(self.classBuilder.valueClass), NSStringFromSelector(_initializer)];
}

-(void) willResolve {
    [super willResolve];
    [ALCRuntime validateClass:self.classBuilder.valueClass selector:_initializer];
}

-(id) invokeWithArgs:(NSArray<id> *) arguments {
    ALCBuilder *builder = self.classBuilder;
    STLog(builder.valueClass, @"Instantiating a %@ using %@", NSStringFromClass(builder.valueClass), self);
    id object = [[builder.valueClass alloc] invokeSelector:_initializer arguments:arguments];
    return object;
}

-(BOOL)canInjectDependencies {
    return self.classBuilder.ready;
}

-(void)injectDependencies:(id)object {
    [self.classBuilder injectDependencies:object];
}

-(NSString *)attributeText {
    return [NSString stringWithFormat:@", using initializer [%@]", [self builderName]];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"initializer [%@]", self.builderName];
}

@end

NS_ASSUME_NONNULL_END

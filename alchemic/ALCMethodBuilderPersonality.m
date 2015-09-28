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

-(ALCBuilderPersonalityType)type {
    return ALCBuilderPersonalityTypeMethod;
}

-(NSString *) builderName {
    return [NSString stringWithFormat:@"%@ %@", NSStringFromClass(self.classBuilder.valueClass), NSStringFromSelector(_selector)];
}

-(void) willResolve {

    [super willResolve];

    [ALCRuntime validateClass:self.classBuilder.valueClass selector:_selector];

    // Go find the class builder for the return type and get it to tell us when it's available.
    ALCBuilder *builder = self.builder;
    Class valueClass = builder.valueClass;
    STLog(builder.valueClass, @"Searching for class builder for method return type %@", NSStringFromClass(valueClass));
    _returnTypeBuilder = [[ALCAlchemic mainContext] builderForClass:valueClass];
    if (_returnTypeBuilder != nil) {
        STLog(builder.valueClass, @"Watching method return type builder");
        [builder addDependency:_returnTypeBuilder];
    } else {
        STLog(builder.valueClass, @"No class builder found for method return type %@", NSStringFromClass(valueClass));
    }
}

-(id) invokeWithArgs:(NSArray<id> *) arguments {
    STLog(_returnType, @"Instantiating a %@ using %@", NSStringFromClass(_returnType), self);
    id factoryObject = self.classBuilder.value;
    id object = [factoryObject invokeSelector:_selector arguments:arguments];
    return object;
}

-(BOOL)canInjectDependencies {
    return _returnTypeBuilder.ready;
}

-(void)injectDependencies:(id)object {
    if (_returnTypeBuilder != nil) {
        [_returnTypeBuilder injectDependencies:object];
    }
}

-(NSString *)attributeText {
    return [NSString stringWithFormat:@", using method [%@]", [self builderName]];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"method [%@]", self.builderName];
}

@end

NS_ASSUME_NONNULL_END

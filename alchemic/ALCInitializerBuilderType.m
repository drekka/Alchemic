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

hideInitializerImpl(initWithType:(Class) valueClass classBuilder:(ALCBuilder *) classBuilder)

-(instancetype) initWithClassBuilder:(ALCBuilder *) classBuilder
                         initializer:(SEL) initializer {
    self = [super initWithType:classBuilder.valueClass classBuilder:classBuilder];
    if (self) {
        _initializer = initializer;
    }
    return self;
}

-(NSString *) defaultName {
    return [NSString stringWithFormat:@"%@ %@", NSStringFromClass(self.classBuilder.valueClass), NSStringFromSelector(_initializer)];
}

-(void) builderWillResolve:(ALCBuilder *) builder {
    [super builderWillResolve:builder];
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

-(ALCBuilder *) classBuilderForInjectingDependencies:(ALCBuilder *)currentBuilder {
    return self.classBuilder;
}

-(NSString *)attributeText {
    return [NSString stringWithFormat:@", using initializer [%@]", self.defaultName];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"initializer [%@]", self.defaultName];
}

@end

NS_ASSUME_NONNULL_END

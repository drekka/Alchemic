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

@synthesize name = _name;

hideInitializerImpl(init)

-(instancetype) initWithClassBuilder:(ALCBuilder *) classBuilder
                         initializer:(SEL) initializer {
    self = [super initWithClassBuilder:classBuilder];
    if (self) {
        _initializer = initializer;
        _name = [NSString stringWithFormat:@"%@ %@", NSStringFromClass(self.classBuilder.valueClass), NSStringFromSelector(_initializer)];
    }
    return self;
}

-(Class)valueClass {
    return self.classBuilder.valueClass;
}

-(NSUInteger)macroProcessorFlags {
    return ALCAllowedMacrosArg;
}

-(void)builder:(ALCBuilder *)builder isConfiguringWithMacroProcessor:(ALCMacroProcessor *)macroProcessor {
    NSString *classBuilderCustomName = self.classBuilder.macroProcessor.asName;
    if (classBuilderCustomName) {
        _name = classBuilderCustomName;
    }
    [super builder:builder isConfiguringWithMacroProcessor:macroProcessor];
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
    return [NSString stringWithFormat:@", using initializer [%@]", self.name];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"initializer [%@]", self.name];
}

@end

NS_ASSUME_NONNULL_END

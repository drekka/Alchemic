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

-(instancetype) initWithParentClassBuilder:(ALCBuilder *) parentClassBuilder
                               initializer:(SEL) initializer {
    self = [super initWithParentClassBuilder:parentClassBuilder];
    if (self) {
        _initializer = initializer;
        _name = [NSString stringWithFormat:@"%@ %@", NSStringFromClass(self.parentClassBuilder.valueClass), NSStringFromSelector(_initializer)];
    }
    return self;
}

-(Class)valueClass {
    return self.parentClassBuilder.valueClass;
}

-(NSUInteger)macroProcessorFlags {
    return ALCAllowedMacrosArg;
}

-(void) configureWithBuilder:(ALCBuilder *) builder {

    [super configureWithBuilder:builder];

    // Grab details from the parent classes macro processor.
    NSString *parentClassBuilderCustomName = self.parentClassBuilder.macroProcessor.asName;
    if (parentClassBuilderCustomName) {
        _name = parentClassBuilderCustomName;
    }

    // Initializers will need to ensure the parent is configured.
    [self.parentClassBuilder configure];

}


-(void) builderWillResolve:(ALCBuilder *) builder {
    [super builderWillResolve:builder];
    [ALCRuntime validateClass:self.parentClassBuilder.valueClass selector:_initializer];
}

-(id) invokeWithArgs:(NSArray<id> *) arguments {
    ALCBuilder *builder = self.parentClassBuilder;
    STLog(builder.valueClass, @"Instantiating a %@ using %@", NSStringFromClass(builder.valueClass), self);
    id object = [[builder.valueClass alloc] invokeSelector:_initializer arguments:arguments];
    return object;
}

-(BOOL)canInjectDependencies {
    return self.parentClassBuilder.ready;
}

-(ALCBuilder *) classBuilderForInjectingDependencies:(ALCBuilder *)currentBuilder {
    return self.parentClassBuilder;
}

-(NSString *)attributeText {
    return [NSString stringWithFormat:@", using initializer [%@]", self.name];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"initializer [%@]", self.name];
}

@end

NS_ASSUME_NONNULL_END

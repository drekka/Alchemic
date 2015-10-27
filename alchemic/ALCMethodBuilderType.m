//
//  ALCBuilderType.m
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import <StoryTeller/StoryTeller.h>

#import "ALCMethodBuilderType.h"
#import "ALCBuilder.h"
#import "ALCMacroProcessor.h"
#import "NSObject+Builder.h"
#import "ALCRuntime.h"
#import "ALCContext.h"
#import "Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodBuilderType {
    SEL _selector;
    ALCBuilder *_returnTypeBuilder;
    Class _valueClass;
}

@synthesize name = _name;

hideInitializerImpl(initWithType:(Class) valueClass classBuilder:(ALCBuilder *) classBuilder)

-(instancetype) initWithType:(Class) valueClass
          parentClassBuilder:(ALCBuilder *) parentClassBuilder
                    selector:(SEL) selector {
    self = [super initWithParentClassBuilder:parentClassBuilder];
    if (self) {
        _selector = selector;
        _valueClass = valueClass;
        _name = [NSString stringWithFormat:@"%@ %@", NSStringFromClass(self.parentClassBuilder.valueClass), NSStringFromSelector(_selector)];
    }
    return self;
}

-(Class)valueClass {
    return _valueClass;
}

-(NSUInteger)macroProcessorFlags {
    return ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary + ALCAllowedMacrosArg;
}

-(void) configureWithBuilder:(ALCBuilder *) builder {
    [super configureWithBuilder:builder];

    NSString *customName = builder.macroProcessor.asName;
    if (customName) {
        _name = customName;
    }

}

-(void) builderWillResolve:(ALCBuilder *)builder {

    [super builderWillResolve:builder];

    [ALCRuntime validateClass:self.parentClassBuilder.valueClass selector:_selector];

    // Go find the class builder for the return type and get it to tell us when it's available.
    STLog(self.valueClass, @"Locating class builder for return type %@", NSStringFromClass(self.valueClass));
    _returnTypeBuilder = [[ALCAlchemic mainContext] classBuilderForClass:self.valueClass];
    if (_returnTypeBuilder != nil) {
        STLog(builder.valueClass, @"Watching class builder for return type");
        [builder addDependency:_returnTypeBuilder];
    } else {
        STLog(self.valueClass, @"No class builder found for method returning a %@", NSStringFromClass(self.valueClass));
    }
}

-(id) invokeWithArgs:(NSArray<id> *) arguments {
    STLog(self.valueClass, @"Instantiating a %@ using %@", NSStringFromClass(self.valueClass), self);
    id factoryObject = self.parentClassBuilder.value;
    id object = [factoryObject invokeSelector:_selector arguments:arguments];
    return object;
}

-(BOOL)canInjectDependencies {
    return ! _returnTypeBuilder || _returnTypeBuilder.ready;
}

-(ALCBuilder *)classBuilderForInjectingDependencies:(ALCBuilder *)currentBuilder {
    return _returnTypeBuilder;
}

-(NSString *)attributeText {
    return [NSString stringWithFormat:@", using method [%@]", NSStringFromSelector(_selector)];
}

-(NSString *) description {
    return [NSString stringWithFormat:@"method [%@]", self.name];
}

@end

NS_ASSUME_NONNULL_END

//
//  ALCBuilderType.m
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCClassBuilderType.h"
#import "ALCBuilder.h"
#import "ALCMacroProcessor.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCClassBuilderType

@synthesize valueClass = _valueClass;
@synthesize name = _name;

hideInitializerImpl(init)

-(instancetype) initWithType:(Class) valueClass {
    self = [super init];
    if (self) {
        _valueClass = valueClass;
        _name = NSStringFromClass(_valueClass);
    }
    return self;
}

-(NSUInteger)macroProcessorFlags {
    return ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary + ALCAllowedMacrosExternal;
}

-(void) builder:(ALCBuilder *) builder isConfiguringWithMacroProcessor:(ALCMacroProcessor *) macroProcessor {
    if (macroProcessor.asName != nil) {
        _name = macroProcessor.asName;
    }
}

-(void)builderWillResolve:(ALCBuilder *)builder {}

-(id) instantiateObject {
    STLog(_valueClass, @"Creating a %@", NSStringFromClass(_valueClass));
    id object = [[_valueClass alloc] init];
    return object;
}

-(BOOL)canInjectDependencies {
    return YES;
}

-(ALCBuilder *) classBuilderForInjectingDependencies:(ALCBuilder *) currentBuilder {
    return currentBuilder;
}

-(id)invokeWithArgs:(NSArray<id> *)arguments {
    @throw [NSException exceptionWithName:@"AlchemicUnexpectedInvocation"
                                   reason:[NSString stringWithFormat:@"Cannot perform an invoke on a class builder: %@", self]
                                 userInfo:nil];
}

-(NSString *)attributeText {
    return @", class builder";
}

-(NSString *) description {
    return [NSString stringWithFormat:@"class builder for %@", NSStringFromClass(_valueClass)];
}

@end

NS_ASSUME_NONNULL_END

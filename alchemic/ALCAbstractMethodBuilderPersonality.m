//
//  ALCAbstractMethodBuilderPersonality.m
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import <StoryTeller/StoryTeller.h>
@import ObjectiveC;
#import "ALCAbstractMethodBuilderPersonality.h"
#import "ALCMacroProcessor.h"
#import "ALCValueSource.h"
#import "ALCDependency.h"
#import "ALCBuilder.h"

@implementation ALCAbstractMethodBuilderPersonality {
    NSMutableArray<ALCDependency *> *_arguments;
}

hideInitializerImpl(init)

-(instancetype) initWithClassBuilder:(ALCBuilder *) classBuilder {
    self = [super init];
    if (self) {
        _classBuilder = classBuilder;
        _arguments = [NSMutableArray array];
    }
    return self;
}

-(NSUInteger)macroProcessorFlags {
    return ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary + ALCAllowedMacrosArg;
}

-(void)configureWithMacroProcessor:(ALCMacroProcessor *)macroProcessor {

    [super configureWithMacroProcessor:macroProcessor];

    // Any dependencies added to this builder macro processor will contain argument data for methods.
    NSUInteger nbrArgs = [macroProcessor valueSourceCount];
    for (NSUInteger i = 0; i < nbrArgs; i++) {
        id<ALCValueSource> valueSource = [macroProcessor valueSourceAtIndex:i];
        ALCDependency *dependency = [[ALCDependency alloc] initWithValueSource:valueSource];
        [(NSMutableArray *)_arguments addObject:dependency];
        [self.builder addDependency:valueSource];
    }
}

-(void)willResolve {
    // Add the class builder as a dependency because we cannot execute a method if the class is still not available.
    [self.builder addDependency:_classBuilder];
}

-(NSArray<id> *)argumentValues {
    // get the values from the arguments
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[_arguments count]];
    for (ALCDependency *argument in _arguments) {
        [values addObject:argument.value];
    }
    return values;
}

-(id) instantiateObject {
    return [self invokeWithArgs:self.argumentValues];
}

-(void) addVariableInjection:(Ivar) variable
          valueSourceFactory:(ALCValueSourceFactory *) valueSourceFactory {
    @throw [NSException exceptionWithName:@"AlchemicUnexpectedInjection"
                                   reason:[NSString stringWithFormat:@"Cannot add a variable dependency for '%s' to a non-class builder: %@", ivar_getName(variable) , self]
                                 userInfo:nil];
}
@end

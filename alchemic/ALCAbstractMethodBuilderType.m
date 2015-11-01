//
//  ALCAbstractMethodBuilderType.m
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//
#import <StoryTeller/StoryTeller.h>
@import ObjectiveC;
#import "ALCAbstractMethodBuilderType.h"
#import "ALCMacroProcessor.h"
#import "ALCValueSource.h"
#import "ALCDependency.h"
#import "ALCBuilder.h"

@implementation ALCAbstractMethodBuilderType {
    NSMutableArray<ALCDependency *> *_arguments;
}

@dynamic name;
@dynamic valueClass;
@dynamic macroProcessorFlags;
@dynamic attributeText;

hideInitializerImpl(init)

-(instancetype) initWithParentClassBuilder:(ALCBuilder *) parentClassBuilder {
    self = [super init];
    if (self) {
        _parentClassBuilder = parentClassBuilder;
        _arguments = [NSMutableArray array];
    }
    return self;
}

-(void) configureWithBuilder:(ALCBuilder *) builder {

    // Any dependencies added to this builder macro processor will contain argument data for methods.
    NSUInteger nbrArgs = [builder.macroProcessor valueSourceCount];
    for (NSUInteger i = 0; i < nbrArgs; i++) {
        id<ALCValueSource> valueSource = [builder.macroProcessor valueSourceAtIndex:i];
        ALCDependency *dependency = [[ALCDependency alloc] initWithValueSource:valueSource];
        [(NSMutableArray *)_arguments addObject:dependency];
        [builder addDependency:valueSource];
    }
}

-(void)builderWillResolve:(ALCBuilder *) builder {
    // Add the class builder as a dependency because we cannot execute a method if the class is still not available.
    [builder addDependency:self.parentClassBuilder];
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

#pragma mark - Methods to override

-(BOOL)canInjectDependencies {
    methodNotImplementedBoolean;
}

-(ALCBuilder *)classBuilderForInjectingDependencies:(ALCBuilder *)currentBuilder {
    methodNotImplementedObject;
}

-(id)invokeWithArgs:(NSArray<id> *)arguments {
    methodNotImplementedObject;
}

@end

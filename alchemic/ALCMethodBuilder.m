//
//  ALCMethodBuilder.m
//  alchemic
//
//  Created by Derek Clarkson on 1/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCMethodBuilder.h"
#import <StoryTeller/StoryTeller.h>

#import "ALCMacroProcessor.h"
#import "ALCBuilder.h"
#import "ALCValueSourceFactory.h"
#import "ALCDependency.h"
#import "ALCInternalMacros.h"
#import "NSObject+Builder.h"
#import "ALCInstantiator.h"
#import "ALCResolvable.h"
#import "ALCClassBuilder.h"
#import "ALCValueSource.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMethodBuilder {
    NSMutableArray<ALCDependency *> *_arguments;
    NSMutableSet<id<ALCResolvable>> *_unavailableArguments;
    ALCClassBuilder *_parentBuilder;
    BOOL _parentBuilderReady;
}

-(instancetype) initWithInstantiator:(id<ALCInstantiator>) instantiator
                            forClass:(Class) aClass {
    return nil;
}

-(instancetype) initWithInstantiator:(id<ALCInstantiator>) instantiator
                            forClass:(Class) aClass
                       parentBuilder:(ALCClassBuilder *) parentBuilder {
    self = [super initWithInstantiator:instantiator forClass:aClass];
    if (self) {
        _arguments = [NSMutableArray array];
        _parentBuilder = parentBuilder;
        blockSelf;
        [_parentBuilder executeWhenAvailable:^(id<ALCResolvable>  _Nonnull resolvable) {
            strongSelf->_parentBuilderReady = YES;
            [self autoBoot];
        }];
    }
    return self;
}

#pragma mark - Overrides

-(NSUInteger)macroProcessorFlags {
    return ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary + ALCAllowedMacrosArg;
}

-(void) configure {

    [super configure];

    // Any dependencies added to this builder macro processor will contain argument data for methods.
    NSUInteger nbrArgs = [self.macroProcessor valueSourceCount];
    if (nbrArgs > 0) {
        blockSelf;
        for (NSUInteger i = 0; i < nbrArgs; i++) {
            id<ALCValueSource> arg = [self.macroProcessor valueSourceAtIndex:i
                                                               whenAvailable:^(id<ALCResolvable> resolvable) {
                                                                   // Remove the dependency from the unavailable list.
                                                                   [strongSelf->_unavailableArguments removeObject:resolvable];
                                                                   [strongSelf autoBoot];
                                                               }];
            ALCDependency *dependency = [[ALCDependency alloc] initWithValueSource:arg];
            [_arguments addObject:dependency];
        }
    }

}

-(void) autoBoot {

    if ([_unavailableArguments count] > 0) {
        return;
    }

    // Clear the storage.
    _unavailableArguments = nil;

    [super autoBoot];
}

-(BOOL)builderReady {
    return super.builderReady
    && _parentBuilderReady
    && [_unavailableArguments count] == 0;
}

-(void)setValue:(id)value {
    // Check if all dependencies are available. Don't check storage.
    if ([_arguments count] > 0) {
        @throw [NSException exceptionWithName:@"AlchemicDependenciesNotAvailable"
                                       reason:[NSString stringWithFormat:@"Dependencies not available: %@, cannot set a value.", self]
                                     userInfo:nil];
    }
    STLog(self.valueClass, @"Injecting a %@", NSStringFromClass([value class]));
    [_parentBuilder injectDependencies:value];
    [super setValue:value];
}

-(void)resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors
                             dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {

    // Copy the instantiator and dependencies to the unresolved dependencies set so we tick them off by removing them.
    // Note we are copying th value sources as that is what is checked.
    _unavailableArguments = [NSMutableSet setWithCapacity:[_arguments count]];
    [_arguments enumerateObjectsUsingBlock:^(ALCDependency * argument, NSUInteger idx, BOOL * stop) {
        [self->_unavailableArguments addObject:argument.valueSource];
    }];

    // Add ourselves to the stack and resolve so we can detect circular dependencies through arguments when creating objects.
    [dependencyStack addObject:self];
    for (ALCDependency *argument in _arguments) {
        STLog(self.valueClass, @"Resolving %@", argument);
        [argument resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];
    }
    [dependencyStack removeObject:self];

    // Make sure that the parent is resolved.
    [_parentBuilder resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];

    // Call super last so that everything is setup for dependency checking.
    [super resolveDependenciesWithPostProcessors:postProcessors dependencyStack:dependencyStack];
}

-(id)instantiateObject {
    // get the values from the arguments
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[_arguments count]];
    for (ALCDependency *argument in _arguments) {
        [values addObject:argument.value];
    }
    return [self.instantiator instantiateWithClassBuilder:_parentBuilder arguments:values];
}

#pragma mark - Method builder

-(id) invokeWithArgs:(NSArray *) arguments {
    return [self.instantiator instantiateWithClassBuilder:_parentBuilder arguments:arguments];
}

@end

NS_ASSUME_NONNULL_END

//
//  ALCClassBuilder.m
//  alchemic
//
//  Created by Derek Clarkson on 1/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCClassBuilder.h"
#import <StoryTeller/StoryTeller.h>

#import "ALCMacroProcessor.h"
#import "ALCBuilder.h"
#import "ALCValueSourceFactory.h"
#import "ALCVariableDependency.h"
#import "ALCInternalMacros.h"
#import "NSObject+Builder.h"
#import "ALCInstantiator.h"
#import "ALCValueSource.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCClassBuilder {
    NSMutableSet<ALCDependency *> *_dependencies;
    NSMutableSet<id<ALCResolvable>> *_unavailableDependencies;
}

#pragma mark - Overrides

-(instancetype) initWithInstantiator:(id<ALCInstantiator>) instantiator
                            forClass:(Class) aClass {
    self = [super initWithInstantiator:instantiator forClass:aClass];
    if (self) {
        _dependencies = [NSMutableSet set];
    }
    return self;
}

-(NSUInteger)macroProcessorFlags {
    return ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary + ALCAllowedMacrosExternal;
}

-(void) autoBoot {

    if ([_unavailableDependencies count] > 0) {
        return;
    }

    // Clear the storage.
    _unavailableDependencies = nil;

    [super autoBoot];
}

-(void)resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors
                             dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {

    // Copy the instantiator and dependencies to the unresolved dependencies set so we tick them off by removing them.
    // Note we need to add the value sources as that is what will be returned by the callbacks.
    _unavailableDependencies = [NSMutableSet setWithCapacity:[_dependencies count]];
    [_dependencies enumerateObjectsUsingBlock:^(ALCDependency * dependency, BOOL * stop) {
        [self->_unavailableDependencies addObject:dependency.valueSource];
    }];

    // We don't add ourselves to the stack here because variable dependencies are injected at a later stage.
    for (ALCDependency *dependency in _dependencies) {
        STLog(self.valueClass, @"Resolving %@", dependency);
        [dependency resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];
    }

    // Call super last so that dependencie checking is done when instantiators, etc come online.
    [super resolveDependenciesWithPostProcessors:postProcessors dependencyStack:dependencyStack];
}

-(id)instantiateObject {
    return [self.instantiator instantiateWithClassBuilder:self arguments:nil];
}

-(BOOL)builderReady {
    return super.builderReady && [_unavailableDependencies count] == 0;
}

-(void)setValue:(id)value {
    // Check if all dependencies are available. Don't check storage.
    if ([_dependencies count] > 0) {
        @throw [NSException exceptionWithName:@"AlchemicDependenciesNotAvailable"
                                       reason:[NSString stringWithFormat:@"Dependencies not available: %@, cannot set a value.", self]
                                     userInfo:nil];
    }
    STLog(self.valueClass, @"Injecting a %@", NSStringFromClass([value class]));
    [self injectDependencies:value];
    [super setValue:value];
}

#pragma mark - Class builder

-(void) addVariableInjection:(Ivar) variable
          valueSourceFactory:(ALCValueSourceFactory *) valueSourceFactory {

    blockSelf;
    id<ALCValueSource> valueSource = [valueSourceFactory valueSourceWithWhenAvailable:^(id<ALCResolvable> resolvable) {
        // Remove the dependency from the unavaulable list.
        [strongSelf->_unavailableDependencies removeObject:resolvable];
        [strongSelf autoBoot];
    }];
    ALCVariableDependency *dep = [[ALCVariableDependency alloc] initWithVariable:variable valueSource:valueSource];

    STLog(self.valueClass, @"Adding variable dependency %@.%@", NSStringFromClass(self.valueClass), dep);
    [_dependencies addObject:dep];
}

-(void)injectDependencies:(id)object {
    [object injectWithDependencies:(NSArray<ALCVariableDependency *> *)_dependencies];
}

@end

NS_ASSUME_NONNULL_END

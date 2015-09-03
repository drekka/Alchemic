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
    NSMutableSet<ALCVariableDependency *> *_dependencies;
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

-(void)resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors
                             dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {

    [super resolveDependenciesWithPostProcessors:postProcessors dependencyStack:dependencyStack];

    // Variable dependencies are regarded as a new dependency stack because they are not immediately required when processing objects.
    for (ALCDependency *dependency in _dependencies) {
        STLog(self.valueClass, @"Resolving %@", dependency);
        [dependency.valueSource resolveWithPostProcessors:postProcessors dependencyStack:[NSMutableArray array]];
    }
}

-(id)instantiateObject {
    return [self.instantiator instantiateWithClassBuilder:self arguments:nil];
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

    id<ALCValueSource> valueSource = valueSourceFactory.valueSource;
    ALCVariableDependency *dep = [[ALCVariableDependency alloc] initWithVariable:variable valueSource:valueSource];

    STLog(self.valueClass, @"Adding variable dependency %@.%@", NSStringFromClass(self.valueClass), dep);
    [_dependencies addObject:dep];
    [self watchResolvable:valueSource];
}

-(void)injectDependencies:(id)object {
    [object injectWithDependencies:_dependencies];
}

@end

NS_ASSUME_NONNULL_END

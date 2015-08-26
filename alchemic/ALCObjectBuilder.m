//
//  ALCObjectBuilder.m
//  alchemic
//
//  Created by Derek Clarkson on 23/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>

#import "ALCObjectBuilder.h"
#import "ALCBuilderDependencyManager.h"
#import "NSObject+ALCResolvable.h"
#import "ALCSingletonStorage.h"
#import "ALCFactoryStorage.h"
#import "ALCExternalStorage.h"
#import "ALCClassInstantiator.h"
#import "ALCMethodInstantiator.h"
#import "ALCMacroProcessor.h"
#import "ALCDependency.h"
#import "ALCVariableDependency.h"
#import "NSObject+Builder.h"
#import "ALCObjectBuilder+ClassBuilder.h"
#import "ALCObjectBuilder+MethodBuilder.h"

NS_ASSUME_NONNULL_BEGIN

// These properties are being made writable.
@interface ALCObjectBuilder ()
@property (nonatomic, assign) BOOL available;
@property (nonatomic, strong) NSString *name;
@end

@implementation ALCObjectBuilder {
    id<ALCValueStorage> _valueStorage;
    id<ALCInstantiator> _instantiator;
    ALCBuilderDependencyManager<ALCVariableDependency *> *_variableDependencies;
    ALCBuilderDependencyManager<ALCDependency *> *_methodArguments;
    BOOL _autoStart;
}

#pragma mark - Properties

@synthesize builderType = _builderType;
@synthesize valueClass = _valueClass;
@synthesize primary = _primary;
@synthesize macroProcessor = _macroProcessor;

#pragma mark - Lifecycle

-(void) dealloc {
    [self kvoRemoveWatchAvailable:_methodArguments];
    [self kvoRemoveWatchAvailable:_variableDependencies];
}

-(instancetype) init {
    return nil;
}

-(instancetype) initWithInstantiator:(id<ALCInstantiator>) instantiator
                            forClass:(Class) aClass {
    self = [super init];
    if (self) {

        _autoStart = YES;
        _valueStorage = [[ALCSingletonStorage alloc] init];
        _instantiator = instantiator;
        _valueClass = aClass;
        _name = _instantiator.builderName;

        if ([instantiator isKindOfClass:[ALCClassInstantiator class]]) {
            _builderType = ALCBuilderTypeClass;
        } else if ([instantiator isKindOfClass:[ALCMethodInstantiator class]]) {
            _builderType = ALCBuilderTypeMethod;
        } else {
            _builderType = ALCBuilderTypeInitializer;
        }
        _macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:[self macroProcessorFlagsForBuilderType:_builderType]];

        _methodArguments = [[ALCBuilderDependencyManager alloc] init];
        [self kvoWatchAvailable:_methodArguments];
        _variableDependencies = [[ALCBuilderDependencyManager alloc] init];
        [self kvoWatchAvailable:_variableDependencies];
    }
    return self;
}

-(void) configure {

    if (self.macroProcessor.isFactory) {
        _valueStorage = [[ALCFactoryStorage alloc] init];
        _autoStart = NO;
    } else if (self.macroProcessor.isExternal) {
        _valueStorage = [[ALCExternalStorage alloc] init];
        _autoStart = NO;
    }

    _primary = self.macroProcessor.isPrimary;
    NSString *newName = self.macroProcessor.asName;
    if (newName != nil) {
        self.name = newName; // Triggers KVO in the model to update the name.
    }

    // Add dependencies.
    // Any dependencies added to this builder macro processor will contain argument data for methods.
    NSUInteger nbrArgs = [self.macroProcessor valueSourceCount];
    if (nbrArgs > 0) {
        for (NSUInteger i = 0; i < nbrArgs; i++) {
            id<ALCValueSource> arg = [self.macroProcessor valueSourceAtIndex:i];
            ALCDependency *dependency = [[ALCDependency alloc] initWithValueSource:arg];
            [_methodArguments addDependency:dependency];
        }
    }

}

-(void)resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors
                 dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {

    // Check for circular dependencies
    if ([dependencyStack containsObject:self]) {
        [dependencyStack addObject:self];
        @throw [NSException exceptionWithName:@"AlchemicCircularDependency"
                                       reason:[NSString stringWithFormat:@"Circular dependency detected: %@",
                                               [dependencyStack componentsJoinedByString:@" -> "]]
                                     userInfo:nil];
    }

    [dependencyStack addObject:self];
    [_variableDependencies resolveWithPostProcessors:postProcessors
                                     dependencyStack:dependencyStack];
    [_methodArguments resolveWithPostProcessors:postProcessors
                                dependencyStack:dependencyStack];
    [dependencyStack removeObject:self];

    // Now pass the resolve through to the initiator which may pass through to the parent builder.
    [_instantiator resolveWithPostProcessors:postProcessors
                             dependencyStack:dependencyStack];

    STLog(self.valueClass, @"Finished resolving, checking availability");
    _available = [self isAvailable];
    [self autoBoot];
}

#pragma mark - Tasks

-(void) addVariableInjection:(Ivar) variable
                 valueSource:(id<ALCValueSource>) valueSource {
    ALCVariableDependency *dep = [[ALCVariableDependency alloc] initWithVariable:variable valueSource:valueSource];
    STLog(self.valueClass, @"Adding variable dependency %@.%@", NSStringFromClass(self.valueClass), dep);
    [_variableDependencies addDependency:dep];
}

-(void)injectDependencies:(id)object {
    [object injectWithDependencies:_variableDependencies];
}

-(id) invokeWithArgs:(NSArray *) arguments {
    if (self.builderType == ALCBuilderTypeClass) {
        @throw [NSException exceptionWithName:@"AlchemicWrongBuilderType"
                                       reason:[NSString stringWithFormat:@"Invoke requires a method or initializer builder, current builder: %@", self]
                                     userInfo:nil];
    }
    id value = [_instantiator instantiateWithArguments:arguments];
    [self injectDependencies:value];
    return value;
}

#pragma mark - Getters and setters

-(id)value {
    id value = _valueStorage.value;
    if (value == nil) {
        value = [_instantiator instantiateWithArguments:_methodArguments.dependencyValues];
        self.value = value;
    }
    return value;
}

-(void)setValue:(id)value {
    STLog(self.valueClass, @"Storing a %@", NSStringFromClass([value class]));
    _valueStorage.value = value;
    STLog(self.valueClass, @"Injecting a %@", NSStringFromClass([value class]));
    [self injectDependencies:value];
    [self updateAvailable];
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(nullable NSString *)keyPath
                     ofObject:(nullable id)object
                       change:(nullable NSDictionary<NSString *,id> *)change
                      context:(nullable void *)context {
    // Dependencies have come online.
    STLog(self.valueClass, @"Dependencies available");
    [self updateAvailable];
    [self autoBoot];
}

#pragma mark - Debug

-(nonnull NSString *) description {
    NSString *instantiated = _valueStorage.hasValue ? @"* " : @"  ";
    return [NSString stringWithFormat:@"%@builder for type %@, name '%@'%@%@", instantiated, NSStringFromClass(self.valueClass), self.name, _valueStorage.attributeText, _instantiator.attributeText];
}

#pragma mark - Internal

-(NSUInteger) macroProcessorFlagsForBuilderType:(ALCBuilderType) builderType {
    if (builderType == ALCBuilderTypeClass) {
        return ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary + ALCAllowedMacrosExternal;
    } else {
        return ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary + ALCAllowedMacrosArg;
    }
}

-(void) autoBoot {
    if (self.available
        && _autoStart
        && !_valueStorage.hasValue) {
        STLog(self.valueClass, @"All dependencies now available, auto-creating a %@ ...", NSStringFromClass(self.valueClass));
        [self value];
    }
}

-(void) updateAvailable {
    if (!self.available && [self isAvailable]) {
        self.available = YES; // Trigger KVO
    }
}

-(BOOL) isAvailable {
    return _valueStorage.hasValue || (
    _variableDependencies.available
    && _methodArguments.available
    && _valueStorage.available
    && _instantiator.available
    );
}

@end

NS_ASSUME_NONNULL_END

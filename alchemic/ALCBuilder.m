//
//  ALCObjectBuilder.m
//  alchemic
//
//  Created by Derek Clarkson on 23/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>

#import "ALCBuilder.h"

#import "ALCBuilderStorageSingleton.h"
#import "ALCBuilderStorageFactory.h"
#import "ALCBuilderStorageExternal.h"

#import "ALCBuilderType.h"
#import "ALCClassBuilderType.h"
#import "ALCMethodBuilderType.h"

#import "ALCMacroProcessor.h"

#import "NSObject+Builder.h"
#import "ALCInternalMacros.h"

#import "ALCValueSourceFactory.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCBuilder {
    id<ALCBuilderStorage> _builderStorage;
    id<ALCBuilderType> _builderType;
    BOOL _isApplicationDelegate;
}

#pragma mark - Lifecycle

hideInitializerImpl(init)

- (instancetype)initWithBuilderType : (id<ALCBuilderType>)builderType {

    self = [super init];
    if (self) {

        _builderType = builderType;
        _name = _builderType.defaultName;

        // Setup the macro processor with the appropriate flags.
        _macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:_builderType.macroProcessorFlags];
    }
    return self;
}

- (void)configure {

    // If the class builder is for the app delegate then ensure it is set as external, nonfactory.
    if ([self.valueClass conformsToProtocol:@protocol(UIApplicationDelegate)]) {
        STLog(self, @"Configuring application delegate builder: %@", self);
        _isApplicationDelegate = YES;
    }

    if (_macroProcessor.isFactory) {
        _builderStorage = [[ALCBuilderStorageFactory alloc] init];
    } else if (self.macroProcessor.isExternal) {
        _builderStorage = [[ALCBuilderStorageExternal alloc] init];
    } else {
        _builderStorage = [[ALCBuilderStorageSingleton alloc] init];
    }

    _primary = _macroProcessor.isPrimary;
    NSString *newName = _macroProcessor.asName;
    if (newName != nil) {
        _name = newName; // Triggers KVO so that the model updates the name.
    }

    [_builderType builder:self isConfiguringWithMacroProcessor:_macroProcessor];
    STLog(self.valueClass, @"Builder for %@ configured: %@", NSStringFromClass(self.valueClass), [self description]);
}

#pragma mark - Tasks

- (void)addVariableInjection:(Ivar)variable
          valueSourceFactory:(ALCValueSourceFactory *)valueSourceFactory {
    id<ALCValueSource> valueSource = valueSourceFactory.valueSource;
    ALCVariableDependency *dep = [[ALCVariableDependency alloc] initWithVariable:variable valueSource:valueSource];

    STLog(self.valueClass, @"Adding variable dependency %@.%@", NSStringFromClass(self.valueClass), dep);
    if (!_variableInjections) {
        _variableInjections = [NSMutableSet set];
    }
    [(NSMutableSet *)_variableInjections addObject:dep];

    // Add the value source as a resolvable dependency so it will be resolved.
    [self addDependency:(id<ALCResolvable>)valueSource];
}

- (void)instantiate {
    if ([_builderStorage isKindOfClass:[ALCBuilderStorageSingleton class]] && !_builderStorage.hasValue) {
        STLog(self.valueClass, @"All dependencies now available, auto-creating a %@ ...", NSStringFromClass(self.valueClass));
        [self value];
    }
}

- (void)willResolve {
    [_builderType builderWillResolve:self];
}

- (void)didResolve {
    if (_isApplicationDelegate) {
        STLog(self.valueClass, @"Setting application delegate ...");
        self.value = [UIApplication sharedApplication].delegate;
    }
}

- (id)invokeWithArgs:(NSArray<id> *)arguments {
    id value = [_builderType invokeWithArgs:arguments];
    [self injectDependencies:value];
    return value;
}

#pragma mark - Getters and setters

-(BOOL) isClassBuilder {
    return [_builderType isKindOfClass:[ALCClassBuilderType class]];
}

-(Class) valueClass {
    return _builderType.valueClass;
}

- (BOOL)ready {
    return super.ready && _builderStorage.ready;
}

-(NSMutableSet<ALCVariableDependency *> *)variableDependencies {
    return (NSMutableSet<ALCVariableDependency *> *)self.dependencies;
}

- (id)value {

    if (!self.ready) {
        @throw [NSException exceptionWithName:@"AlchemicBuilderNotAvailable"
                                       reason:[NSString stringWithFormat:@"Builder %@ still has pending dependencies.", self]
                                     userInfo:nil];
    }

    id value = _builderStorage.value;
    if (value == nil) {
        value = [_builderType instantiateObject];
        [self setValue:value];
    }

    return value;
}

// Allows us to inject dependencies on objects created outside of Alchemic.
- (void)setValue:(id)value {

    // If this builder is external, it will be a class builder so we just check the super dependencies.
    // Otherwise check with the builder type.
    if (([_builderStorage isKindOfClass:[ALCBuilderStorageExternal class]] && super.ready) || _builderType.canInjectDependencies) {
        // Always store first in case circular dependencies trigger via the dependency injection loop back here before we have stored it.
        _builderStorage.value = value;
        [self injectDependencies:value];
    } else {
        @throw [NSException exceptionWithName:@"AlchemicDependenciesNotAvailable"
                                       reason:[NSString stringWithFormat:@"Dependencies not available for builder: %@", self]
                                     userInfo:nil];
    }
}

- (void)injectDependencies:(id)object {
    ALCBuilder *dependencySource = [_builderType classBuilderForInjectingDependencies:self];
    [object injectWithDependencies:dependencySource.variableInjections];
}

#pragma mark - Debug

- (nonnull NSString *)description {
    NSString *instantiated = _builderStorage.hasValue ? @"* " : @"  ";
    NSString *appDelegate = _isApplicationDelegate ? @" (Application delegate)" : @"";
    return [NSString stringWithFormat:@"%@builder for type %@%@, name '%@'%@%@", instantiated, NSStringFromClass(self.valueClass), appDelegate, self.name, _builderStorage.attributeText, _builderType.attributeText];
}

@end

NS_ASSUME_NONNULL_END

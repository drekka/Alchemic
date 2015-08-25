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

@interface ALCObjectBuilder ()
@property (nonatomic, assign) BOOL available;
@end

@implementation ALCObjectBuilder {
    id<ALCValueStorage> _valueStorage;
    id<ALCInstantiator> _instantiator;
    ALCBuilderDependencyManager<ALCVariableDependency *> *_variableDependencies;
    ALCBuilderDependencyManager<ALCDependency *> *_methodArguments;
}

#pragma mark - Properties

@synthesize builderType = _builderType;
@synthesize createOnBoot = _createOnBoot;
@synthesize available = _available;
@synthesize valueClass = _valueClass;
@synthesize name = _name;
@synthesize primary = _primary;
@synthesize macroProcessor = _macroProcessor;

#pragma mark - Lifecycle

-(void) dealloc {
    [_variableDependencies removeObserver:self forKeyPath:@"dependencyManager"];
    [_methodArguments removeObserver:self forKeyPath:@"dependencyManager"];
}

-(instancetype) init {
    return nil;
}

-(instancetype) initWithStorage:(id<ALCValueStorage>) storage
                   instantiator:(id<ALCInstantiator>) instantiator
                       forClass:(Class) aClass {
    self = [super init];
    if (self) {
        _valueStorage = storage;
        _instantiator = instantiator;
        _valueClass = aClass;
        _macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:[self macroProcessorFlagsForBuilder:instantiator]];
        _methodArguments = [[ALCBuilderDependencyManager alloc] init];
        [_methodArguments addObserver:self
                           forKeyPath:@"dependencyManager"
                              options:NSKeyValueObservingOptionNew
                              context:&_methodArguments];
        _variableDependencies = [[ALCBuilderDependencyManager alloc] init];
        [_variableDependencies addObserver:self
                                forKeyPath:@"dependencyManager"
                                   options:NSKeyValueObservingOptionNew
                                   context:&_variableDependencies];
        if ([instantiator isKindOfClass:[ALCClassInstantiator class]]) {
            _builderType = ALCBuilderTypeClass;
        } else if ([instantiator isKindOfClass:[ALCMethodInstantiator class]]) {
            _builderType = ALCBuilderTypeMethod;
        } else {
            _builderType = ALCBuilderTypeInitializer;
        }
    }
    return self;
}

-(void) configure {

    if (self.macroProcessor.isFactory) {
        _valueStorage = [[ALCFactoryStorage alloc] init];
    }

    _primary = self.macroProcessor.isPrimary;
    _createOnBoot = !self.macroProcessor.isFactory;
    _name = self.macroProcessor.asName;
    if (_name != nil) {
        _name = _instantiator.builderName;
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
    STLog(self.valueClass, @"Resolving %@", self);

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

    // Now pass the rsolve through to the initiator which may pass through to the parent builder.
    [_instantiator resolveWithPostProcessors:postProcessors
                             dependencyStack:dependencyStack];

    _available = [self isAvailable];

}

#pragma mark - Tasks

-(void) addVariableInjection:(Ivar) variable
                 valueSource:(id<ALCValueSource>) valueSource {
    ALCVariableDependency *dep = [[ALCVariableDependency alloc] initWithVariable:variable valueSource:valueSource];
    STLog(self.valueClass, @"Adding variable dependency %@.%@", NSStringFromClass(self.valueClass), dep);
    [self kvoWatchAvailable:dep];
    [_variableDependencies addDependency:dep];
}

-(void)injectDependencies:(id)object {
    [object injectWithDependencies:_variableDependencies];
}

-(id) invokeWithArgs:(NSArray *) arguments {
    if (self.builderType != ALCBuilderTypeMethod) {
        @throw [NSException exceptionWithName:@"AlchemicWrongBuilderType"
                                       reason:[NSString stringWithFormat:@"Cannot execute a method on a non-method builder: %@", self]
                                     userInfo:nil];
    }
    return [self valueWithArguments:arguments];
}

#pragma mark - Getters and setters

-(id)value {
    return [self valueWithArguments:_methodArguments.dependencyValues];
}

-(void)setValue:(id)value {
    [self injectDependencies:value];
    _valueStorage.value = value;
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(nullable NSString *)keyPath
                     ofObject:(nullable id)object
                       change:(nullable NSDictionary<NSString *,id> *)change
                      context:(nullable void *)context {
    // Dependencies have come online.
    self.available = [self isAvailable];

    // If we are available and we represent something that is not a factory or external then we are a singleton so auto build.
    if (self.available
        && [_valueStorage isKindOfClass:[ALCSingletonStorage class]]) {
        [self value];
    }
}

#pragma mark - Debug

-(nonnull NSString *) description {
    NSString *instantiated = _valueStorage.hasValue ? @"* " : @"  ";
    NSString *attributes = @"";
    return [NSString stringWithFormat:@"%@'%@' Class builder for type %@%@", instantiated, self.name, NSStringFromClass(self.valueClass), attributes];
}

#pragma mark - Internal

-(NSUInteger) macroProcessorFlagsForBuilder:(id<ALCInstantiator>) instantiator {
    if ([instantiator isKindOfClass:[ALCClassInstantiator class]]) {
        return ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary;
    } else {
        return ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary + ALCAllowedMacrosArg;
    }
}

-(BOOL) isAvailable {
    return _variableDependencies.available
    && _methodArguments.available
    && _valueStorage.available
    && _instantiator.available;
}

-(id) valueWithArguments:(NSArray *) arguments {

    id value = _valueStorage.value;

    // If a factory or not created yet. Build.
    if (value == nil) {
        STLog(self.valueClass, @"Instanting %@ ...", self);
        value = [_instantiator instantiateWithArguments:arguments];
        [value injectWithDependencies:_variableDependencies];
    }

    STLog(self, @"Returning a %@", NSStringFromClass([value class]));
    return value;
}


@end

NS_ASSUME_NONNULL_END

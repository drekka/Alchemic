//
//  ALCObjectBuilder.m
//  alchemic
//
//  Created by Derek Clarkson on 23/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>

#import "ALCAbstractBuilder.h"

#import "ALCSingletonStorage.h"
#import "ALCFactoryStorage.h"
#import "ALCExternalStorage.h"

#import "ALCMethodInstantiator.h"

#import "ALCMacroProcessor.h"
#import "NSObject+Builder.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

// These properties are being made writable.
@interface ALCAbstractBuilder ()
@property (nonatomic, strong) NSString *name;
@end

@implementation ALCAbstractBuilder {
    id<ALCValueStorage> _valueStorage;
    BOOL _autoStart;
}

#pragma mark - Properties

@synthesize valueClass = _valueClass;
@synthesize primary = _primary;
@synthesize macroProcessor = _macroProcessor;

#pragma mark - Lifecycle

hideInitializerImpl(init)

-(instancetype) initWithInstantiator:(id<ALCInstantiator>) instantiator
                            forClass:(Class) aClass {
    self = [super init];
    if (self) {

        _autoStart = YES;
        _valueStorage = [[ALCSingletonStorage alloc] init];
        _instantiator = instantiator;
        _valueClass = aClass;
        _name = _instantiator.builderName;

        // Add the instantiator as a dependency.
        [self watchResolvable:instantiator];

        // Setup the macro processor with the appropriate flags.
        _macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:self.macroProcessorFlags];

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
        self.name = newName; // Triggers KVO so that the model updates the name.
    }

}

#pragma mark - Tasks

-(void)didBecomeAvailable {
    if (_autoStart && !_valueStorage.hasValue) {
        STLog(self.valueClass, @"All dependencies now available, auto-creating a %@ ...", NSStringFromClass(self.valueClass));
        [self value];
    }
}

-(void)resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors
                             dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {
    [self watchResolvable:_instantiator];
    [_instantiator resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];
}

-(BOOL) available {
    return super.available && _valueStorage.available;
}

#pragma mark - Getters and setters

-(id)value {

    if (!self.available) {
        @throw [NSException exceptionWithName:@"AlchemicBuilderNotAvailable"
                                       reason:[NSString stringWithFormat:@"Builder %@ is not available. Dependencies are still pending.", self]
                                     userInfo:nil];}

    id value = _valueStorage.value;
    if (value == nil) {
        value = [self instantiateObject];
        _valueStorage.value = value;// Dont go through the setter because the instantiator will have injected dependencies.
    }

    return value;
}

// Allows us to inject dependencies on objects created outside of Alchemic.
-(void)setValue:(id)value {
    STLog(self.valueClass, @"Storing a %@", NSStringFromClass([value class]));
    _valueStorage.value = value;
    [self checkIfAvailable];
}

#pragma mark - Debug

-(nonnull NSString *) description {
    NSString *instantiated = _valueStorage.hasValue ? @"* " : @"  ";
    return [NSString stringWithFormat:@"%@builder for type %@, name '%@'%@%@", instantiated, NSStringFromClass(self.valueClass), self.name, _valueStorage.attributeText, _instantiator.attributeText];
}

#pragma mark - Override methods

-(NSUInteger) macroProcessorFlags {
    methodNotImplementedInt;
}

-(id) instantiateObject {
    methodNotImplementedObject;
}

@end

NS_ASSUME_NONNULL_END

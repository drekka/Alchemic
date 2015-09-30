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

#import "ALCSingletonStorage.h"
#import "ALCFactoryStorage.h"
#import "ALCExternalStorage.h"

#import "ALCBuilderPersonality.h"
#import "ALCMacroProcessor.h"

#import "NSObject+Builder.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

// These properties are being made writable.
@interface ALCBuilder ()
@property (nonatomic, strong) NSString *name;
@end

@implementation ALCBuilder {
    id<ALCValueStorage> _valueStorage;
    BOOL _autoStart;
    id<ALCBuilderPersonality> _personality;
}

#pragma mark - Properties

@synthesize valueClass = _valueClass;
@synthesize primary = _primary;
@synthesize macroProcessor = _macroProcessor;

#pragma mark - Lifecycle

hideInitializerImpl(init)

-(instancetype)initWithPersonality:(id<ALCBuilderPersonality>)personality forClass:(Class)aClass {

    self = [super init];
    if (self) {

        // Set the back ref in the personality.
        personality.builder = self;

        _autoStart = YES;
        _personality = personality;
        _valueClass = aClass;
        _name = _personality.builderName;

        // Setup the macro processor with the appropriate flags.
        _macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:_personality.macroProcessorFlags];

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
    } else {
        _valueStorage = [[ALCSingletonStorage alloc] init];
        _autoStart = YES;
    }

    _primary = self.macroProcessor.isPrimary;
    NSString *newName = self.macroProcessor.asName;
    if (newName != nil) {
        self.name = newName; // Triggers KVO so that the model updates the name.
    }

    [_personality configureWithMacroProcessor:_macroProcessor];
    STLog(self.valueClass, @"Builder for %@ configured: %@", NSStringFromClass(self.valueClass), [self description]);

}

#pragma mark - Tasks


-(void) addVariableInjection:(Ivar) variable
          valueSourceFactory:(ALCValueSourceFactory *) valueSourceFactory {
    [_personality addVariableInjection:variable valueSourceFactory:valueSourceFactory];
}

-(void) instantiate {
    if (_autoStart && !_valueStorage.hasValue) {
        STLog(self.valueClass, @"All dependencies now available, auto-creating a %@ ...", NSStringFromClass(self.valueClass));
        [self value];
    }
}

-(void) willResolve {
    [_personality willResolve];
}

-(id) invokeWithArgs:(NSArray<id> *) arguments {
    id value = [_personality invokeWithArgs:arguments];
    [_personality injectDependencies:value];
    return value;
}

#pragma mark - Getters and setters

-(ALCBuilderPersonalityType) type {
    return _personality.type;
}

-(id)value {

    if (!self.ready) {
        @throw [NSException exceptionWithName:@"AlchemicBuilderNotAvailable"
                                       reason:[NSString stringWithFormat:@"Builder %@ still has pending dependencies.", self]
                                     userInfo:nil];}

    id value = _valueStorage.value;
    if (value == nil) {
        value = [_personality instantiateObject];
        [self setValue:value];
    }

    return value;
}

// Allows us to inject dependencies on objects created outside of Alchemic.
-(void)setValue:(id) value {

    if (! _personality.canInjectDependencies) {
        @throw [NSException exceptionWithName:@"AlchemicDependenciesNotAvailable"
                                       reason:[NSString stringWithFormat:@"Dependencies not available for builder: %@", self]
                                     userInfo:nil];
    }

    // Always store first in case circular dependencies trigger via the dependency injection and loop back here before we have stored it.
    _valueStorage.value = value;
    [_personality injectDependencies:value];
    [self ready];
}

-(void)injectDependencies:(id) object {
    [_personality injectDependencies:object];
}

#pragma mark - Debug

-(nonnull NSString *) description {
    NSString *instantiated = _valueStorage.hasValue ? @"* " : @"  ";
    return [NSString stringWithFormat:@"%@builder for type %@, name '%@'%@%@", instantiated, NSStringFromClass(self.valueClass), self.name, _valueStorage.attributeText, _personality.attributeText];
}

@end

NS_ASSUME_NONNULL_END

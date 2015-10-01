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
#import "ALCMacroProcessor.h"

#import "NSObject+Builder.h"
#import "ALCInternalMacros.h"

NS_ASSUME_NONNULL_BEGIN

// These properties are being made writable.
@interface ALCBuilder ()
@property (nonatomic, strong) NSString *name;
@end

@implementation ALCBuilder {
    id<ALCBuilderStorage> _builderStorage;
    id<ALCBuilderType> _builderType;
}

#pragma mark - Properties

@synthesize valueClass = _valueClass;
@synthesize primary = _primary;
@synthesize macroProcessor = _macroProcessor;

#pragma mark - Lifecycle

hideInitializerImpl(init)

-(instancetype)initWithALCBuilderType:(id<ALCBuilderType>)builderType forClass:(Class)aClass {

    self = [super init];
    if (self) {

        // Set the back ref in the builderType.
        builderType.builder = self;

        _builderType = builderType;
        _valueClass = aClass;
        _name = _builderType.builderName;

        // Setup the macro processor with the appropriate flags.
        _macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:_builderType.macroProcessorFlags];

    }
    return self;
}

-(void) configure {

    if (self.macroProcessor.isFactory) {
        _builderStorage = [[ALCBuilderStorageFactory alloc] init];
    } else if (self.macroProcessor.isExternal) {
        _builderStorage = [[ALCBuilderStorageExternal alloc] init];
    } else {
        _builderStorage = [[ALCBuilderStorageSingleton alloc] init];
    }

    _primary = self.macroProcessor.isPrimary;
    NSString *newName = self.macroProcessor.asName;
    if (newName != nil) {
        self.name = newName; // Triggers KVO so that the model updates the name.
    }

    [_builderType configureWithMacroProcessor:_macroProcessor];
    STLog(self.valueClass, @"Builder for %@ configured: %@", NSStringFromClass(self.valueClass), [self description]);

}

#pragma mark - Tasks


-(void) addVariableInjection:(Ivar) variable
          valueSourceFactory:(ALCValueSourceFactory *) valueSourceFactory {
    [_builderType addVariableInjection:variable valueSourceFactory:valueSourceFactory];
}

-(void) instantiate {
    if ([_builderStorage isKindOfClass:[ALCBuilderStorageSingleton class]] && !_builderStorage.hasValue) {
        STLog(self.valueClass, @"All dependencies now available, auto-creating a %@ ...", NSStringFromClass(self.valueClass));
        [self value];
    }
}

-(void) willResolve {
    [_builderType willResolve];
}

-(id) invokeWithArgs:(NSArray<id> *) arguments {
    id value = [_builderType invokeWithArgs:arguments];
    [_builderType injectDependencies:value];
    return value;
}

#pragma mark - Getters and setters

-(ALCBuilderType) type {
    return _builderType.type;
}

-(BOOL)ready {
    return super.ready && _builderStorage.ready;
}

-(id)value {

    if (!self.ready) {
        @throw [NSException exceptionWithName:@"AlchemicBuilderNotAvailable"
                                       reason:[NSString stringWithFormat:@"Builder %@ still has pending dependencies.", self]
                                     userInfo:nil];}

    id value = _builderStorage.value;
    if (value == nil) {
        value = [_builderType instantiateObject];
        [self setValue:value];
    }

    return value;
}

// Allows us to inject dependencies on objects created outside of Alchemic.
-(void)setValue:(id) value {

    // If this builder is external, it will be a class builder so we just check the super dependencies.
    // Otherwise check with the builder type.
    if (([_builderStorage isKindOfClass:[ALCBuilderStorageExternal class]] && super.ready)
        || _builderType.canInjectDependencies) {
        // Always store first in case circular dependencies trigger via the dependency injection loop back here before we have stored it.
        _builderStorage.value = value;
        [_builderType injectDependencies:value];
    } else {
        @throw [NSException exceptionWithName:@"AlchemicDependenciesNotAvailable"
                                       reason:[NSString stringWithFormat:@"Dependencies not available for builder: %@", self]
                                     userInfo:nil];
    }

}

-(void)injectDependencies:(id) object {
    [_builderType injectDependencies:object];
}

#pragma mark - Debug

-(nonnull NSString *) description {
    NSString *instantiated = _builderStorage.hasValue ? @"* " : @"  ";
    return [NSString stringWithFormat:@"%@builder for type %@, name '%@'%@%@", instantiated, NSStringFromClass(self.valueClass), self.name, _builderStorage.attributeText, _builderType.attributeText];
}

@end

NS_ASSUME_NONNULL_END

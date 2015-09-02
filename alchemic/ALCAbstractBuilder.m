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
    BOOL _resolved;
    BOOL _instantiatorReady;
    NSMutableSet<ALCWhenAvailableBlock> *_whenAvailableBlocks;
}

#pragma mark - Properties

@synthesize valueClass = _valueClass;
@synthesize primary = _primary;
@synthesize macroProcessor = _macroProcessor;

#pragma mark - Lifecycle

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
        _whenAvailableBlocks = [NSMutableSet set];

        blockSelf;
        instantiator.whenAvailable = ^(id<ALCResolvable> resolvable) {
            strongSelf->_instantiatorReady = YES; // Remove the dependency from the unavailable list.
            [strongSelf autoBoot];
        };

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

-(void)resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors
                 dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {

    // Check for circular dependencies first.
    if ([dependencyStack containsObject:self]) {
        [dependencyStack addObject:self];
        @throw [NSException exceptionWithName:@"AlchemicCircularDependency"
                                       reason:[NSString stringWithFormat:@"Circular dependency detected: %@",
                                               [dependencyStack componentsJoinedByString:@" -> "]]
                                     userInfo:nil];
    }

    // If already resolved then abort. This can occur as various dependencies resolve back to the original builder.
    if (_resolved) {
        STLog(self.valueClass, @"Previously resolved");
    } else {
        // Flag that we are resolved so we can abort endless resolution loops.
        _resolved = YES;
        [self resolveDependenciesWithPostProcessors:postProcessors dependencyStack:dependencyStack];
    }

}


-(void)executeWhenAvailable:(ALCWhenAvailableBlock)whenAvailable {
    if (_whenAvailableBlocks == nil) {
        whenAvailable(self);
    } else {
        [_whenAvailableBlocks addObject:[whenAvailable copy]];
    }
}

#pragma mark - Tasks

-(void) autoBoot {

    if ([self builderReady]) {

        STLog(self, @"All dependencies available, executing when available blocks");

        // Move the blocks so that multithreading won't interfer and will execute blocks immediately.
        NSMutableSet<ALCWhenAvailableBlock> *blocks = _whenAvailableBlocks;
        _whenAvailableBlocks = nil;
        for (ALCWhenAvailableBlock whenAvailable in blocks) {
            whenAvailable(self);
        }

        if (_autoStart && !_valueStorage.hasValue) {
            STLog(self.valueClass, @"All dependencies now available, auto-creating a %@ ...", NSStringFromClass(self.valueClass));
            [self value];
        }
    }
}

-(void)resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors
                             dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {

    // Now pass the resolve through to the initiator which may pass through to the parent builder if it has one.
    [_instantiator resolveWithPostProcessors:postProcessors dependencyStack:dependencyStack];

}

-(BOOL)builderReady {
    return _valueStorage.available && _instantiatorReady;
}

#pragma mark - Getters and setters

-(id)value {

    if (!self.builderReady) {
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
    // Now check if we should trigger callbacks.
    [self autoBoot];
}

#pragma mark - Debug

-(nonnull NSString *) description {
    NSString *instantiated = _valueStorage.hasValue ? @"* " : @"  ";
    return [NSString stringWithFormat:@"%@builder for type %@, name '%@'%@%@", instantiated, NSStringFromClass(self.valueClass), self.name, _valueStorage.attributeText, _instantiator.attributeText];
}

#pragma mark - Override methods

-(NSUInteger) macroProcessorFlags {
    [self doesNotRecognizeSelector:_cmd];
    return 0;
}

-(id) instantiateObject {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

@end

NS_ASSUME_NONNULL_END

//
//
//  Created by Derek Clarkson on 9/05/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCAbstractMethodBuilder.h"
#import "ALCRuntime.h"
#import "ALCClassBuilder.h"
#import "ALCMacroProcessor.h"
#import "ALCDependency.h"
#import "ALCArg.h"
#import "ALCAlchemic.h"
#import "ALCContext.h"
#import "ALCInternalMacros.h"
#import "NSObject+Alchemic.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractMethodBuilder {
    NSArray *_overrideArguments;
    BOOL _useClassMethod;
    SEL _selector;
}

-(instancetype) init {
    return nil;
}

-(instancetype) initWithParentClassBuilder:(ALCClassBuilder *) parentClassBuilder
                                  selector:(SEL) selector {
    self = [super init];
    if (self) {
        _parentClassBuilder = parentClassBuilder;
        _selector = selector;
        self.macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosArg + ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary];
        self.name = [NSString stringWithFormat:@"%@ %@", NSStringFromClass(self.parentClassBuilder.valueClass), NSStringFromSelector(_selector)];
    }
    return self;
}

-(void)configure {
    [super configure];
    for (NSUInteger i = 0; i < [self.macroProcessor valueSourceCount]; i++) {
        id<ALCValueSource> arg = [self.macroProcessor valueSourceAtIndex:i];
        [self.dependencies addObject:[[ALCDependency alloc] initWithValueSource:arg]];
    }
    [ALCRuntime validateClass:self.parentClassBuilder.valueClass
                     selector:_selector
               macroProcessor:self.macroProcessor];
}

-(void)resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors {
    [super resolveWithPostProcessors:postProcessors];
    if ( ! self.parentClassBuilder.resolved) {
        STLog(self.valueClass, @"resolving dependencies in parent %@", self.parentClassBuilder);
        [self.parentClassBuilder resolveWithPostProcessors:postProcessors];
    }
}

// Override the the value property to check for a one off request.
-(id) value {

    if (_overrideArguments == nil) {
        return super.value;
    }

    // Create a instance, inject it and return without storing.
    STLog(self.valueClass, @"Instanting with override args %@ ...", self);
    id newValue = [self instantiateObject];
    [self injectValueDependencies:newValue];
    return newValue;

}

-(id) instantiateObject {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id) invokeMethodOn:(id) target {

    // If there are override arguments then use those. Otherwise get the arguments from the dependencies.
    NSArray *finalArguments;
    if (_overrideArguments == nil) {
        // Generate an array of arguments from the dependencies.
        finalArguments = [[NSMutableArray alloc] initWithCapacity:[self.dependencies count]];
        for (ALCDependency *dependency in self.dependencies) {
            [(NSMutableArray *)finalArguments addObject:dependency.value];
        }
    } else {
        // Use the overrides and clear as they are always a one shot thing.
        finalArguments = _overrideArguments;
        _overrideArguments = nil;
    }

    return [target invokeSelector:_selector arguments:finalArguments];
}

-(id) invokeWithArgs:(NSArray *) arguments {
    _overrideArguments = arguments;
    return self.value;
}

-(void) injectValueDependencies:(id) value {
    // Pass this to the parent class to finish injecting.
    [self.parentClassBuilder injectValueDependencies:value];
}

-(nonnull NSString *) description {
    return [NSString stringWithFormat:@"-[%@ %@]", NSStringFromClass(self.parentClassBuilder.valueClass), NSStringFromSelector(_selector)];
}

@end

NS_ASSUME_NONNULL_END

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
    [self validateClass:self.parentClassBuilder.valueClass
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

-(id)instantiateObject {
    // Generate an array of arguments from the dependencies.
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithCapacity:[self.dependencies count]];
    for (ALCDependency *dependency in self.dependencies) {
        [arguments addObject:dependency.value];
    }
    return [self instantiateObjectWithArguments:arguments];
}

-(id) instantiateObjectWithArguments:(NSArray<id> *) arguments {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

-(id) invokeMethodOn:(id) target withArguments:(NSArray<id> *) arguments {
    return [target invokeSelector:_selector arguments:arguments];
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

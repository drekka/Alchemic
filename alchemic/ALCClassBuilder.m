//
//  ALCConstructorInfo.m
//  alchemic
//
//  Created by Derek Clarkson on 23/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

#import "ALCClassBuilder.h"

@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>

#import "ALCRuntime.h"
#import "ALCVariableDependency.h"
#import "ALCClassBuilder.h"
#import "ALCMacroProcessor.h"
#import "ALCModelValueSource.h"
#import "ALCValueSourceFactory.h"
#import "AlchemicAware.h"
#import "NSObject+ALCResolvable.h"

@implementation ALCClassBuilder

-(instancetype) init {
    return nil;
}

@synthesize external = _external;

-(instancetype) initWithValueClass:(__unsafe_unretained Class) valueClass {
    self = [super init];
    if (self) {
        self.valueClass = valueClass;
        self.macroProcessor = [[ALCMacroProcessor alloc] initWithAllowedMacros:ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary];
        self.name = NSStringFromClass(valueClass);
    }
    return self;
}

#pragma mark - Configuring

-(void) configure {
    [super configure];
    NSString *name = self.macroProcessor.asName;
    if (name != nil) {
        self.name = name;
    }
}

-(void)resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {
    _available = _dependenciesAvailable && !_external;

}

#pragma mark - Adding dependencies

-(void) addVariableInjection:(Ivar) variable class:(Class) aClass macroProcessor:(ALCMacroProcessor *) macroProcessor {
    id<ALCValueSource> valueSource = [macroProcessor valueSourceAtIndex:0];
    valueSource.valueClass = aClass;
    ALCVariableDependency *dep = [[ALCVariableDependency alloc] initWithVariable:variable valueSource:valueSource];
    STLog(self.valueClass, @"Adding variable dependency %@.%@", NSStringFromClass(self.valueClass), dep);
    [self kvoWatchAvailable:dep];
    [self.dependencies addObject:dep];
    // Don't update state as this executes before resolving occurs.
}

-(void)injectDependencies:(id) value {

    if ([self.dependencies count] > 0u) {
        STLog([value class], @"Injecting %lu dependencies into a %s instance", [self.dependencies count], object_getClassName(value));
        for (ALCVariableDependency *dependency in self.dependencies) {
            [dependency injectInto:value];
        }
    }

    if ([value respondsToSelector:@selector(alchemicDidInjectDependencies)]) {
        STLog([value class], @"Notifying that inject did finish");
        [value alchemicDidInjectDependencies];
    }
}

#pragma mark - Instantiating

-(nonnull id) instantiateObject {
    STLog(self.valueClass, @"Creating a %@", NSStringFromClass(self.valueClass));
    return [[self.valueClass alloc] init];
}

-(NSString *) attributesDescription {
    return [super.attributesDescription stringByAppendingString: self.external ? @" (external)" : @""];
}

-(nonnull NSString *) description {
    return [NSString stringWithFormat:@"%@'%@' Class builder for type %s%@", [self stateDescription], self.name, class_getName(self.valueClass), self.attributesDescription];
}

@end

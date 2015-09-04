//
//  ALCBuilderPersonality.m
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCClassBuilderPersonality.h"
#import "ALCBuilder.h"
#import "ALCMacroProcessor.h"
#import "ALCVariableDependency.h"
#import "ALCValueSource.h"
#import "NSObject+Builder.h"
#import "ALCValueSourceFactory.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCClassBuilderPersonality {
    NSMutableSet<ALCVariableDependency *> *_dependencies;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _dependencies = [NSMutableSet set];
    }
    return self;
}

-(ALCPersonalityType)type {
    return ALCPersonalityTypeClass;
}

-(NSString *) builderName {
    return NSStringFromClass(self.builder.valueClass);
}

-(NSUInteger)macroProcessorFlags {
    return ALCAllowedMacrosFactory + ALCAllowedMacrosName + ALCAllowedMacrosPrimary + ALCAllowedMacrosExternal;
}

-(void) addVariableInjection:(Ivar) variable
          valueSourceFactory:(ALCValueSourceFactory *) valueSourceFactory {

    id<ALCValueSource> valueSource = valueSourceFactory.valueSource;
    ALCVariableDependency *dep = [[ALCVariableDependency alloc] initWithVariable:variable valueSource:valueSource];

    ALCBuilder *builder = self.builder;
    STLog(builder.valueClass, @"Adding variable dependency %@.%@", NSStringFromClass(builder.valueClass), dep);
    [_dependencies addObject:dep];
    [builder watchResolvable:valueSource];
}

-(void)resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *)postProcessors
                             dependencyStack:(NSMutableArray<id<ALCResolvable>> *)dependencyStack {

    [super resolveDependenciesWithPostProcessors:postProcessors dependencyStack:dependencyStack];

    // Variable dependencies are regarded as a new dependency stack because they are not immediately required when processing objects.
    for (ALCVariableDependency *dependency in _dependencies) {
        STLog(self.builder.valueClass, @"Resolving variable dependency %@", dependency);
        [dependency.valueSource resolveWithPostProcessors:postProcessors dependencyStack:[NSMutableArray array]];
    }
}

-(id) instantiateObject {
    ALCBuilder *builder = self.builder;
    STLog(builder.valueClass, @"Creating a %@", NSStringFromClass(builder.valueClass));
    id object = [[builder.valueClass alloc] init];
    [self injectDependencies:object];
    return object;
}

-(BOOL)canInjectDependencies {
    return self.builder.available;
}

-(void)injectDependencies:(id)object {
    [object injectWithDependencies:_dependencies];
}

-(id)invokeWithArgs:(NSArray<id> *)arguments {
    @throw [NSException exceptionWithName:@"AlchemicUnexpectedInvokation"
                                   reason:[NSString stringWithFormat:@"Cannot perform an invoke on a class builder: %@", self]
                                 userInfo:nil];
}

-(NSString *)attributeText {
    return @", class builder";
}

@end

NS_ASSUME_NONNULL_END

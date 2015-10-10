//
//  ALCBuilderType.m
//  alchemic
//
//  Created by Derek Clarkson on 4/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <StoryTeller/StoryTeller.h>

#import "ALCClassBuilderType.h"
#import "ALCBuilder.h"
#import "ALCMacroProcessor.h"
#import "ALCVariableDependency.h"
#import "ALCValueSource.h"
#import "NSObject+Builder.h"
#import "ALCValueSourceFactory.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCClassBuilderType {
    NSMutableSet<ALCVariableDependency *> *_dependencies;
}

-(instancetype)init {
    self = [super init];
    if (self) {
        _dependencies = [NSMutableSet set];
    }
    return self;
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
    [builder addDependency:valueSource];
}

-(id) instantiateObject {
    ALCBuilder *builder = self.builder;
    STLog(builder.valueClass, @"Creating a %@", NSStringFromClass(builder.valueClass));
    id object = [[builder.valueClass alloc] init];
    return object;
}

-(BOOL)canInjectDependencies {
    return self.builder.ready;
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

-(NSString *) description {
    return [NSString stringWithFormat:@"class builder for %@", NSStringFromClass(self.builder.valueClass)];
}

@end

NS_ASSUME_NONNULL_END

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
#import <Alchemic/Alchemic.h>

#import "ALCRuntime.h"
#import "ALCVariableDependency.h"
#import "ALCClassBuilder.h"
#import "ALCVariableDependencyMacroProcessor.h"
#import "ALCModelValueSource.h"
#import "ALCClassInitializerBuilder.h"

@implementation ALCClassBuilder {
	NSMutableSet<ALCVariableDependency*> *_dependencies;
}

-(instancetype) initWithValueClass:(__unsafe_unretained __nonnull Class) valueClass
										name:(NSString * __nonnull)name {
	self = [super initWithValueClass:valueClass name:name];
	if (self) {
		_dependencies = [[NSMutableSet alloc] init];
	}
	return self;
}

#pragma mark - Adding dependencies

-(void) addInjectionPointForArguments:(ALCVariableDependencyMacroProcessor *) arguments {
	[_dependencies addObject:[[ALCVariableDependency alloc] initWithVariable:arguments.variable
																					 valueSource:[arguments valueSource]]];
}

#pragma mark - Instantiating

-(void) resolveDependenciesWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> *) postProcessors {
	[_dependencies enumerateObjectsUsingBlock:^(ALCVariableDependency * __nonnull dependency, BOOL * __nonnull stop) {
		[dependency resolveWithPostProcessors:postProcessors];
	}];
}

-(nonnull id) instantiateObject {
	
	if (self.initializerBuilder != nil) {
		return [self.initializerBuilder instantiate];
	}

	STLog(self.valueClass, @"Creating a %@", NSStringFromClass(self.valueClass));
	return [[self.valueClass alloc] init];
}

-(void) injectObjectDependencies:(id __nonnull) object {
	STLog([object class], @">>> Injecting %lu dependencies into a %s instance", [_dependencies count], object_getClassName(object));
	for (ALCVariableDependency *dependency in _dependencies) {
		[dependency injectInto:object];
	}
}

-(nonnull NSString *) description {
	return [NSString stringWithFormat:@"Class %@ for type %s", self.factory ? @"factory" : @"builder", class_getName(self.valueClass)];
}

@end

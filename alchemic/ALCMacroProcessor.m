//
//  ALCMethodArgMacroProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import <StoryTeller/StoryTeller.h>

#import "ALCMacroProcessor.h"

#import "ALCValueSourceFactory.h"
#import "ALCModelSearchExpression.h"
#import "ALCValueDefMacro.h"
#import "ALCMacro.h"
#import "ALCIsFactory.h"
#import "ALCWithName.h"
#import "ALCIsPrimary.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCMacroProcessor {
	NSUInteger _allowedMacros;
	NSMutableArray<ALCValueSourceFactory *> *_valueSourceFactories;
}

-(instancetype) initWithAllowedMacros:(NSUInteger) allowedMacros {
	self = [super init];
	if (self) {
		_allowedMacros = allowedMacros;
		_valueSourceFactories = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) addMacro:(id<ALCMacro>) macro {

	if ([macro isKindOfClass:[ALCIsFactory class]] && _allowedMacros & ALCAllowedMacrosFactory) {
		_isFactory = YES;

	} else if ([macro isKindOfClass:[ALCWithName class]] && _allowedMacros & ALCAllowedMacrosName) {
		_asName = ((ALCWithName *)macro).asName;

	} else if ([macro isKindOfClass:[ALCIsPrimary class]] && _allowedMacros & ALCAllowedMacrosPrimary) {
		_isPrimary = YES;

	} else if ([macro isKindOfClass:[ALCValueSourceFactory class]] && _allowedMacros & ALCAllowedMacrosArg) {
		[_valueSourceFactories addObject:(ALCValueSourceFactory *)macro];

	} else if ([macro conformsToProtocol:@protocol(ALCValueDefMacro)] && _allowedMacros & ALCAllowedMacrosValueDef) {
		if ([_valueSourceFactories count] == 0) {
			[_valueSourceFactories addObject:[[ALCValueSourceFactory alloc] init]];
		}
		[_valueSourceFactories[0] addMacro:(id<ALCValueDefMacro>)macro];

	} else {
		@throw [NSException exceptionWithName:@"AlchemicUnexpectedMacro"
												 reason:[NSString stringWithFormat:@"Unexpected macro %@", macro]
											  userInfo:nil];
	}
}

-(ALCValueSourceFactory *) valueSourceFactoryAtIndex:(NSUInteger) index {
	return _valueSourceFactories[index];
}

-(NSUInteger) valueSourceCount {
	return [_valueSourceFactories count];
}

-(NSString *)description {
	NSMutableArray *flags = [[NSMutableArray alloc] init];
	if (self.isFactory) {
		[flags addObject:@"factory"];
	}
	if (self.isPrimary) {
		[flags addObject:@"primary"];
	}
	if (self.asName != nil) {
		[flags addObject:[NSString stringWithFormat:@"name: '%@'", self.asName]];
	}
	if ([self valueSourceCount] > 0u) {
		[flags addObject:[_valueSourceFactories componentsJoinedByString:@", "]];
	}
	return [NSString stringWithFormat:@"Macro processor: %@", [flags componentsJoinedByString:@", "]];
}

@end

NS_ASSUME_NONNULL_END

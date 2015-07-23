//
//  ALCMethodArgMacroProcessor.m
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;

#import "ALCAbstractMacroProcessor.h"

#import "ALCValueSourceFactory.h"
#import "ALCModelSearchExpression.h"
#import "ALCValueDefMacro.h"
#import "ALCMacro.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ALCAbstractMacroProcessor {
	NSMutableArray<ALCValueSourceFactory *> *_valueSourceFactories;
}

-(instancetype) init {
	self = [super init];
	if (self) {
		_valueSourceFactories = [[NSMutableArray alloc] init];
	}
	return self;
}

-(void) addMacro:(id<ALCMacro>) macro {
	if ([macro isKindOfClass:[ALCValueSourceFactory class]]) {
		[_valueSourceFactories addObject:(ALCValueSourceFactory *)macro];
	} else if ([macro conformsToProtocol:@protocol(ALCValueDefMacro)]) {
		if ([_valueSourceFactories count] == 0) {
			[_valueSourceFactories addObject:[[ALCValueSourceFactory alloc] init]];
		}
		[_valueSourceFactories[0] addMacro:(id<ALCValueDefMacro>)macro];
	} else {
		[self raiseUnexpectedMacroError:macro];
	}
}

-(void) raiseUnexpectedMacroError:(id<ALCMacro>) macro {
	@throw [NSException exceptionWithName:@"AlchemicUnexpectedMacro"
											 reason:[NSString stringWithFormat:@"Unexpected macro %@", macro]
										  userInfo:nil];
}

-(ALCValueSourceFactory *) valueSourceFactoryForIndex:(NSUInteger) index {
	return _valueSourceFactories[index];
}

-(NSUInteger) valueSourceCount {
	return [_valueSourceFactories count];
}

-(void) validate {
	for (ALCValueSourceFactory *valueSourceFactory in _valueSourceFactories) {
		[valueSourceFactory validate];
	}
}

@end

NS_ASSUME_NONNULL_END

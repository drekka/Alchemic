//
//  ALCAbstractValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractValueSource.h"

@implementation ALCAbstractValueSource

-(id) valueForType:(nullable Class) finalType {

	NSSet<id> *values = [self values];

	// If we can return an array then do so. Empty arrays are also valid.
	if ((finalType == NULL && [values count] > 1)
		|| [finalType isSubclassOfClass:[NSArray class]]) {
		return [self valuesAsArray:values];
	}

	return [self valuesAsObject:values];
}

-(id) valuesAsObject:(NSSet<id> *) values {

	// Object type and no values.
	if ([values count] == 0u) {
		@throw [NSException exceptionWithName:@"AlchemicNoValuesFound"
												 reason:[NSString stringWithFormat:@"Expecting 1 object, but none found"]
											  userInfo:nil];
	}

	// Not a possible array.
	if ([values count] == 1u) {
		return values.anyObject;
	}

	// finally error.
	@throw [NSException exceptionWithName:@"AlchemicTooManyValues"
											 reason:[NSString stringWithFormat:@"Expecting 1 object, but found %lu", (unsigned long)[values count]]
										  userInfo:nil];
}

-(id) valuesAsArray:(NSSet<id> *) values {
	if ([values count] == 1u && [[values anyObject] isKindOfClass:[NSArray class]]) {
		return values.anyObject;
	}
	return values.allObjects;
}

-(void)resolveWithPostProcessors:(NSSet<id<ALCDependencyPostProcessor>> * _Nonnull)postProcessors{
	[self doesNotRecognizeSelector:_cmd];
}

-(NSSet<id> * _Nonnull)values {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

@end

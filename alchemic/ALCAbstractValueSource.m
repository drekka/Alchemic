//
//  ALCAbstractValueSource.m
//  Alchemic
//
//  Created by Derek Clarkson on 24/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCAbstractValueSource.h"
#import "ALCInternalMacros.h"

@implementation ALCAbstractValueSource

@synthesize valueClass = _valueClass;

hideInitializerImpl(init)

-(instancetype) initWithType:(Class)argumentType {
    self = [super init];
    if (self) {
        _valueClass = argumentType;
    }
    return self;
}

#pragma mark - Getting the value

-(id) value {

    // Check the state
    if (!self.available) {
        @throw [NSException exceptionWithName:@"AlchemicValueNotAvailable"
                                       reason:[NSString stringWithFormat:@"Value not available - %@", self]
                                     userInfo:nil];
    }

	NSSet<id> *values = self.values;

	// If we can return an array then do so. Empty arrays are also valid.
    // NULL means we are dealing with an id type.
    if ([self returnArrayForValues:values]) {
		return [self valuesAsArray:values];
	}

	return [self valuesAsObject:values];
}

-(BOOL) returnArrayForValues:(NSSet<id> *) values {
    // If the type is an id or an NSObject and there is more than one result,
    // Or the type is an array.
    return ((_valueClass == NULL || _valueClass == [NSObject class]) && [values count] > 1)
    || [_valueClass isSubclassOfClass:[NSArray class]];
}

-(id) valuesAsObject:(NSSet<id> *) values {

	// Object type and no values.
	if ([values count] == 0u) {
		@throw [NSException exceptionWithName:@"AlchemicNoValuesFound"
												 reason:@"Expecting 1 value, but none found"
											  userInfo:nil];
	}

	// Not a possible array.
	if ([values count] == 1u) {
		return values.anyObject;
	}

	// finally error.
	@throw [NSException exceptionWithName:@"AlchemicTooManyValues"
											 reason:[NSString stringWithFormat:@"Expecting 1 value, but found %lu instead", (unsigned long)[values count]]
										  userInfo:nil];
}

-(id) valuesAsArray:(NSSet<id> *) values {
	if ([values count] == 1u && [[values anyObject] isKindOfClass:[NSArray class]]) {
		return values.anyObject;
	}
	return values.allObjects;
}

#pragma mark - Override points

-(NSSet<id> *)values {
	methodNotImplementedObject;
}

@end

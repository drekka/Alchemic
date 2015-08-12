//
//  SImpleObject.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "SimpleObject.h"

@implementation SimpleObject

-(instancetype) initAlternative {
	self = [super init];
	if (self) {
		self.aStringProperty = @"xyz";
	}
	return self;
}

-(instancetype) initWithString:(NSString *) aString {
	self = [super init];
	if (self) {
		self.aStringProperty = aString;
	}
	return self;
}

-(NSString *) stringFactoryMethod {
	return @"abc";
}

-(NSString *) stringFactoryMethodUsingAString:(NSString *) aString {
	self.stringFactoryWithAStringCalled = YES;
	return @"abc";
}

-(void) alchemicDidInjectDependencies {
	_didInject = YES;
}

@end

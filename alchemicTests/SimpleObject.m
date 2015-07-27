//
//  SImpleObject.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "SimpleObject.h"

@implementation SimpleObject

-(void) aMethodWithAString:(NSString *) aString{
	_aMethodWithAStringCalled = YES;
}

-(NSString *) stringFactoryMethod {
	return @"abc";
}

-(NSString *) stringFactoryMethodUsingAString:(NSString *) aString {
	self.stringFactoryWithAStringCalled = YES;
	return @"abc";
}

@end

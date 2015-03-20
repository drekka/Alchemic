//
//  NSObject+Alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 18/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@interface NSObject (Alchemic)

/**
 Call just before injecting to ensure that if the value is a proxy is replaced with the target object.
 
 @param objectVariable a pointer to a variable that may contain a ALCObjectProxy.
 */
-(void) resolveProxy:(id *) objectVariable;

@end

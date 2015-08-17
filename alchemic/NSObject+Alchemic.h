//
//  NSObject+Alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 15/08/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Alchemic)

-(id) invokeSelector:(SEL) selector arguments:(NSArray *) arguments;

@end

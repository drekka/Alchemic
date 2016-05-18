//
//  XCTestCase+Alchemic.m
//  alchemic
//
//  Created by Derek Clarkson on 18/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import "XCTestCase+Alchemic.h"

#import <Alchemic/Alchemic.h>

@implementation XCTestCase (Alchemic)

-(void) executeBlockWithException:(Class) exceptionClass block:(ALCSimpleBlock) block {
    @try {
        block();
        XCTFail(@"Exception not thrown");
    }
    @catch (AlchemicException *exception) {
        XCTAssertTrue([exception isKindOfClass:exceptionClass], @"Expected a %@, got a %@ instead", NSStringFromClass(exceptionClass), NSStringFromClass([exception class]));
    }
    @catch (NSException *exception) {
        XCTFail(@"Un-expected exception %@", exception);
    }
}

@end

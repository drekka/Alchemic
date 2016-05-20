//
//  XCTestCase+Alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 18/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

@import Alchemic.Private;

@interface XCTestCase (Alchemic)

-(void) executeBlockWithException:(Class) exceptionClass block:(ALCSimpleBlock) block;

@end

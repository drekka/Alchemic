//
//  XCTestCase+Alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 18/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

@interface XCTestCase (Alchemic)

-(id) getVariable:(NSString *) variable fromObject:(id) obj;

@end

//
//  XCTestCase+Alchemic.h
//  alchemic
//
//  Created by Derek Clarkson on 18/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;

NS_ASSUME_NONNULL_BEGIN

@interface XCTestCase (Alchemic)

-(nullable id) getVariable:(NSString *) variable fromObject:(id) obj;

-(void) setVariable:(NSString *) variable inObject:(id) obj value:(nullable id) value;

@end

NS_ASSUME_NONNULL_END


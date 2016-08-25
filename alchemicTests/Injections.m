//
//  Injections.m
//  Alchemic
//
//  Created by Derek Clarkson on 26/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import XCTest;
@import Alchemic;
@import Alchemic.Private;
@import ObjectiveC;

@interface Injections : XCTestCase

@end

@implementation Injections {

    ALCMapper *_mapper;
    ALCInjectorFactory *_injectorFactory;

    int _aInt;
}

-(void)setUp {
    _mapper = [[ALCMapper alloc] init];
    _injectorFactory = [[ALCInjectorFactory alloc] init];
}

-(void) testNSNumberToInt {

    NSNumber *five = @(5);

    ALCTypeData *fromType = [ALCTypeData typeForEncoding:@encode(NSNumber *)];
    Ivar intVar = class_getInstanceVariable([self class], "_aInt");
    ALCTypeData *toType = [ALCTypeData typeForEncoding:ivar_getTypeEncoding(intVar)];

    [_mapper mapFromType:fromType toType:toType]([NSValue valueWithNonretainedObject:five], [_injectorFactory injectorForIvar:intVar type:toType]);

    XCTAssertEqual(5, _aInt);
}

@end

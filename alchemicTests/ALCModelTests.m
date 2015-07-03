//
//  ALCModelTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 3/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import XCTest;

#import "ALCModel.h"
#import "ALCClassBuilder.h"
#import "ALCType.h"

@interface ALCModelTests : XCTestCase

@end

@implementation ALCModelTests {
    ALCModel *_model;
}

-(void) setUp {
    _model = [[ALCModel alloc] init];
}

-(void) testSaveQueryClass {

    //ALCType *type = [ALCType typeForClass:[self class]];
    //ALCClassBuilder *builder = [[ALCClassBuilder alloc] initWithContext:nil valueType:type];

}

@end

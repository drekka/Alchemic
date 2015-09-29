//
//  ClassIntegrationTests.m
//  Alchemic
//
//  Created by Derek Clarkson on 29/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

#import "ALCTestCase.h"
#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>

@interface MFWithArgParentClass : NSObject
@property (nonatomic, strong) NSMutableArray *createANumberResults;
@end

@implementation MFWithArgParentClass {
    NSUInteger _createANumberMutator;
}

-(instancetype) init {
    self = [super init];
    if (self) {
        self.createANumberResults = [[NSMutableArray alloc] init];
    }
    return self;
}

AcMethod(NSNumber, createANumberFromANumber:, AcArg(NSNumber, AcName(@"abc")), AcWithName(@"def"), AcFactory)
-(NSNumber *) createANumberFromANumber:(NSNumber *) aNumber {
    NSNumber *number = @(2 * ++_createANumberMutator + [aNumber unsignedLongValue]);
    [self.createANumberResults addObject:number];
    return number;
}

@end

@interface MethodFactoryWithArgIntegrationTests : ALCTestCase
@end

@implementation MethodFactoryWithArgIntegrationTests {
    NSNumber *_aNumber3;
    NSNumber *_aNumber4;
    MFWithArgParentClass *_parentClass;
}

AcInject(_aNumber3, AcName(@"def"))
AcInject(_aNumber4, AcName(@"def"))
AcInject(_parentClass)

-(void) testIntegrationCreatingASingletonWithAnArg {
    [self setupRealContext];
    STStartLogging(@"[MethodFactoryIntegrationTests]");
    [self startContextWithClasses:@[[MFWithArgParentClass class], [MethodFactoryWithArgIntegrationTests class]]];
    AcInjectDependencies(self);
    XCTAssertEqual(2u, [_parentClass.createANumberResults count]);
    XCTAssertTrue([_parentClass.createANumberResults containsObject:_aNumber3]);
    XCTAssertTrue([_parentClass.createANumberResults containsObject:_aNumber4]);
    XCTAssertNotEqual(_aNumber3, _aNumber4);
}

@end

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

@interface MFParentClass : NSObject
@property (nonatomic, strong) NSMutableArray *createANumberResults;
@property (nonatomic, strong) NSMutableArray *createANumberWithNumberResults;
@end

@implementation MFParentClass {
	NSUInteger _createANumberMutator;
	NSUInteger _createANumberFromANumberMutator;
}

-(instancetype) init {
	self = [super init];
	if (self) {
		self.createANumberResults = [[NSMutableArray alloc] init];
		self.createANumberWithNumberResults = [[NSMutableArray alloc] init];
	}
	return self;
}

AcMethod(NSNumber, createANumber, AcWithName(@"abc"), AcIsFactory)
-(NSNumber *) createANumber {
	NSNumber *number = @(2 * ++_createANumberMutator);
	[self.createANumberResults addObject:number];
	return number;
}

AcMethod(NSNumber, createANumberFromANumber:, AcArg(NSNumber, AcName(@"abc")), AcWithName(@"def"), AcIsFactory)
-(NSNumber *) createANumberFromANumber:(NSNumber *) aNumber {
	NSNumber *number = @(2 * ++_createANumberFromANumberMutator + [aNumber unsignedLongValue]);
	[self.createANumberWithNumberResults addObject:number];
	return number;
}

@end

@interface MethodFactoryIntegrationTests : ALCTestCase
@end

@implementation MethodFactoryIntegrationTests {
	NSNumber *_aNumber1;
	NSNumber *_aNumber2;
	NSNumber *_aNumber3;
	NSNumber *_aNumber4;
	MFParentClass *_parentClass;
}

AcInject(_aNumber1, AcName(@"abc"))
AcInject(_aNumber2, AcName(@"abc"))
AcInject(_aNumber3, AcName(@"def"))
AcInject(_aNumber4, AcName(@"def"))
AcInject(_parentClass)

-(void) testSimpleFactory {
	[self setupRealContext];
	STStartLogging(ALCHEMIC_LOG);
	STStartLogging(@"[MSParentClass]");
	STStartLogging(@"[MethodSingletonIntegrationTests]");
	[self addClassesToContext:@[[MFParentClass class], [MethodFactoryIntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertEqual(4u, [_parentClass.createANumberResults count]);
	XCTAssertTrue([_parentClass.createANumberResults containsObject:_aNumber1]);
	XCTAssertTrue([_parentClass.createANumberResults containsObject:_aNumber2]);
	XCTAssertTrue([_parentClass.createANumberResults containsObject:@2]);
	XCTAssertTrue([_parentClass.createANumberResults containsObject:@4]);
	XCTAssertTrue([_parentClass.createANumberResults containsObject:@6]);
	XCTAssertTrue([_parentClass.createANumberResults containsObject:@8]);
	XCTAssertNotEqual(_aNumber1, _aNumber2);
}

-(void) testCreatingASingletonWithAnArg {
	[self setupRealContext];
	STStartLogging(@"[MethodSingletonIntegrationTests]");
	[self addClassesToContext:@[[MFParentClass class], [MethodFactoryIntegrationTests class]]];
	AcInjectDependencies(self);
	XCTAssertEqual(2u, [_parentClass.createANumberWithNumberResults count]);
	XCTAssertTrue([_parentClass.createANumberWithNumberResults containsObject:_aNumber3]);
	XCTAssertTrue([_parentClass.createANumberWithNumberResults containsObject:_aNumber4]);
	XCTAssertNotEqual(_aNumber3, _aNumber4);
}

@end

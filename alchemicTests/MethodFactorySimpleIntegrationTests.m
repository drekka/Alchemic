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

@interface MFSimpleParentClass : NSObject
@property (nonatomic, strong) NSMutableArray *createANumberResults;
@end

@implementation MFSimpleParentClass {
	NSUInteger _createANumberMutator;
}

-(instancetype) init {
	self = [super init];
	if (self) {
		self.createANumberResults = [[NSMutableArray alloc] init];
	}
	return self;
}

AcRegister()
AcMethod(NSNumber, createANumber, AcWithName(@"abc"), AcFactory)
-(NSNumber *) createANumber {
	NSNumber *number = @(2 * ++_createANumberMutator);
	[self.createANumberResults addObject:number];
	return number;
}

@end

@interface MethodFactorySimpleIntegrationTests : ALCTestCase
@end

@implementation MethodFactorySimpleIntegrationTests {
	NSNumber *_aNumber1;
	NSNumber *_aNumber2;
	MFSimpleParentClass *_parentClass;
}

AcRegister(AcExternal)
AcInject(_aNumber1, AcName(@"abc"))
AcInject(_aNumber2, AcName(@"abc"))
AcInject(_parentClass)

-(void) testIntegrationSimpleFactory {

    STStartLogging(@"LogAll");
	[self setupRealContext];
    [self startContextWithClasses:@[[MFSimpleParentClass class], [MethodFactorySimpleIntegrationTests class]]];

    AcInjectDependencies(self);

    XCTAssertEqual(2u, [_parentClass.createANumberResults count]);
	XCTAssertTrue([_parentClass.createANumberResults containsObject:_aNumber1]);
	XCTAssertTrue([_parentClass.createANumberResults containsObject:_aNumber2]);
	XCTAssertNotEqual(_aNumber1, _aNumber2);
}

@end

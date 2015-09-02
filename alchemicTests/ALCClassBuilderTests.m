//
//  ALCClassBuilderTests.m
//  alchemic
//
//  Created by Derek Clarkson on 1/09/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import ObjectiveC;
#import <Alchemic/Alchemic.h>
#import <StoryTeller/StoryTeller.h>
#import "ALCTestCase.h"

#import "ALCClassBuilder.h"
#import "SimpleObject.h"
#import "ALCMacroProcessor.h"

@interface ALCClassBuilderTests : ALCTestCase
@end

@implementation ALCClassBuilderTests

-(void) testInject {
    STStartLogging(@"LogAll");
    ALCClassBuilder *builder = [self simpleBuilderForClass:[SimpleObject class]];

    SimpleObject *so = [[SimpleObject alloc] init];
    Ivar var = class_getInstanceVariable([SimpleObject class], "_aStringProperty");
    ALCValueSourceFactory *factory = [[ALCValueSourceFactory alloc] initWithType:[NSString class]];
    [factory addMacro:AcValue(@"abc")];

    [builder addVariableInjection:var valueSourceFactory:factory];
    [self configureAndResolveBuilder:builder];

    [builder injectDependencies:so];

    XCTAssertEqual(@"abc", so.aStringProperty);
}


@end

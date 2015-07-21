//
//  ALCRuntimeScanner.h
//  Alchemic
//
//  Created by Derek Clarkson on 8/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class ALCContext;

typedef BOOL(^ClassSelector)(Class __nonnull aClass);
typedef void(^ClassProcessor)(ALCContext __nonnull *context, Class __nonnull aClass);

@interface ALCRuntimeScanner : NSObject

@property(nonatomic, copy, readonly, nonnull) ClassSelector selector;
@property(nonatomic, copy, readonly, nonnull) ClassProcessor processor;

-(nonnull instancetype) initWithSelector:(ClassSelector __nonnull) selector
                               processor:(ClassProcessor __nonnull) processor;

+(nonnull instancetype) modelScanner;
+(nonnull instancetype) dependencyPostProcessorScanner;
+(nonnull instancetype) objectFactoryScanner;
+(nonnull instancetype) resourceLocatorScanner;

@end

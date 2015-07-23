//
//  ALCRuntimeScanner.h
//  Alchemic
//
//  Created by Derek Clarkson on 8/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class ALCContext;

NS_ASSUME_NONNULL_BEGIN

typedef BOOL(^ClassSelector)(Class aClass);
typedef void(^ClassProcessor)(ALCContext *context, Class aClass);

@interface ALCRuntimeScanner : NSObject

@property(nonatomic, copy, readonly) ClassSelector selector;
@property(nonatomic, copy, readonly) ClassProcessor processor;

-(instancetype) initWithSelector:(ClassSelector) selector
							  processor:(ClassProcessor) processor;

+(instancetype) modelScanner;
+(instancetype) dependencyPostProcessorScanner;
+(instancetype) resourceLocatorScanner;

@end

NS_ASSUME_NONNULL_END

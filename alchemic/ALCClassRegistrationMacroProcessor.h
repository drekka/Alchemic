//
//  ALCClassMacroProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 17/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import ObjectiveC;
@protocol ALCValueSource;

#import "ALCMacroProcessor.h"

NS_ASSUME_NONNULL_BEGIN


@interface ALCClassRegistrationMacroProcessor : ALCMacroProcessor

@property (nonatomic, strong, readonly) NSString *asName;
@property (nonatomic, assign, readonly) BOOL isFactory;
@property (nonatomic, assign, readonly) BOOL isPrimary;

@end

NS_ASSUME_NONNULL_END

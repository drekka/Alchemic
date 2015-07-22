//
//  ALCMethodArgMacroProcessor.h
//  Alchemic
//
//  Created by Derek Clarkson on 18/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class ALCArg;
@protocol ALCValueSourceMacro;

#include "ALCMacroProcessor.h"

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractMacroProcessor : NSObject<ALCMacroProcessor>

@property (nonatomic, strong, readonly) NSMutableArray<id<ALCValueSourceMacro>> *valueSourceMacros;

-(instancetype) initWithParentClass:(Class) parentClass NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

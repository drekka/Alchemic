//
//  ALCAbstractValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 29/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/ALCValueSource.h>

@class ALCType;

@interface ALCAbstractValueSource : NSObject<ALCValueSource>

/**
 Unused initializer.
 */
-(instancetype) init NS_UNAVAILABLE;

/**
 Default tinitializer.
 */
-(instancetype) initWithType:(ALCType *) type NS_DESIGNATED_INITIALIZER;

@end

//
//  ALCInjectorFactory.h
//  Alchemic
//
//  Created by Derek Clarkson on 25/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/ALCTypeDefs.h>
@class ALCTypeData;

NS_ASSUME_NONNULL_BEGIN

@interface ALCInjectorFactory : NSObject

-(nullable ALCInjectorBlock) injectorForIvar:(Ivar) ivar type:(ALCTypeData *) type;

@end

NS_ASSUME_NONNULL_END


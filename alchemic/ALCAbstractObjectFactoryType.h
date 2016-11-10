//
//  ALCAbstractObjectFactoryType.h
//  Alchemic
//
//  Created by Derek Clarkson on 20/06/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/ALCObjectFactoryType.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALCAbstractObjectFactoryType : NSObject<ALCObjectFactoryType>

-(NSString *) descriptionWithType:(NSString *) type;

@end

NS_ASSUME_NONNULL_END

//
//  ALCMethodArgumentDependencyInternal.h
//  alchemic
//
//  Created by Derek Clarkson on 4/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@protocol ALCMethodArgumentDependencyInternal <NSObject>

+(instancetype) argumentWithClass:(Class) argumentClass criteria:(NSArray *) criteria;

@end

NS_ASSUME_NONNULL_END

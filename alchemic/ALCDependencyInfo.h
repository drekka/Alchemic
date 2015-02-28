//
//  ALCDependencyInfo.h
//  alchemic
//
//  Created by Derek Clarkson on 22/02/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

/**
 Container object for information about an injection.
 */
@interface ALCDependencyInfo : NSObject

@property (nonatomic, assign) Class targetClass;

@property (nonatomic, strong) NSString *targetVariable;

@end

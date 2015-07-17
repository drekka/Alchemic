//
//  ALCAsName.h
//  alchemic
//
//  Created by Derek Clarkson on 8/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@interface ALCWithName : NSObject

@property (nonatomic, strong, readonly) NSString *asName;

+(instancetype) withName:(NSString *) name;

@end

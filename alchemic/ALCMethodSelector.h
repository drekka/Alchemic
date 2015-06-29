//
//
//  Created by Derek Clarkson on 7/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@interface ALCMethodSelector : NSObject

@property(nonatomic, assign, readonly) SEL factorySelector;

+(instancetype) methodSelector:(SEL) methodSelector;

@end

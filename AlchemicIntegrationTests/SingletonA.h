//
//  SingletonA.h
//  Alchemic
//
//  Created by Derek Clarkson on 8/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@class SingletonB;

@interface SingletonA : NSObject
@property (nonatomic, strong) SingletonB *singletonB;
@end

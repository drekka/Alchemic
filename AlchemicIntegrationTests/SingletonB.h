//
//  SingletonB.h
//  Alchemic
//
//  Created by Derek Clarkson on 8/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class SingletonA;

@interface SingletonB : NSObject
@property (nonatomic, strong) SingletonA *singletonA;
@end

//
//  FactoryA.h
//  Alchemic
//
//  Created by Derek Clarkson on 23/04/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class SingletonB;

@interface FactoryA : NSObject
@property (nonatomic, strong) SingletonB *singletonB;
@end

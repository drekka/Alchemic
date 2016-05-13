//
//  SingletonC.h
//  Alchemic
//
//  Created by Derek Clarkson on 4/05/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SingletonB;

@interface SingletonC : NSObject
@property (nonatomic, assign, readonly) int aInt;
@property (nonatomic, strong) SingletonB *singletonB;
@end

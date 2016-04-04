//
//  TopObject.h
//  Alchemic
//
//  Created by Derek Clarkson on 14/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
@import UIKit;

@class NestedThing;
@class AnotherThing;

@interface TopThing : NSObject

@property (nonatomic, assign) BOOL aBool;
@property (nonatomic, assign) int aInt;
@property (nonatomic, assign) long aLong;
@property (nonatomic, assign) double aDouble;
@property (nonatomic, assign) float aFloat;

@property (nonatomic, assign) CGFloat aCGFloat;
@property (nonatomic, assign) CGSize aCGSize;
@property (nonatomic, assign) CGRect aCGRect;

@property (nonatomic, strong) NSString *aString;
@property (nonatomic, strong) NestedThing *aNestedThing;
@property (nonatomic, strong) AnotherThing *anotherThing;

@property (nonatomic, strong) NSArray<NestedThing *> *arrayOfNestedThings;

-(instancetype) initWithString:(NSString *) aString;
-(instancetype) initWithString:(NSString *) aString andInt:(int) aInt;
-(instancetype) initWithAnotherThing:(AnotherThing *) anotherThing;

+(instancetype) classCreateWithString:(NSString *) aString;

-(instancetype) factoryMethodWithString:(NSString *) aString;
-(instancetype) factoryMethodWithString:(NSString *) aString andInt:(int) aInt;

@end

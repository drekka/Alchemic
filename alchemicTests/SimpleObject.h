//
//  SImpleObject.h
//  Alchemic
//
//  Created by Derek Clarkson on 26/07/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@interface SimpleObject : NSObject
@property (nonatomic, strong) NSString *aStringProperty;
@property (nonatomic, assign) BOOL aMethodWithAStringCalled;
-(void) aMethodWithAString:(NSString *) aString;
-(NSString *) stringFactoryMethod;
@end

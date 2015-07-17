//
//  ALCReturnType.h
//  alchemic
//
//  Created by Derek Clarkson on 6/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@interface ALCReturnType : NSObject

@property(nonatomic, assign, readonly) Class returnType;

+(instancetype) returnTypeWithClass:(Class) returnTypeClass;

@end

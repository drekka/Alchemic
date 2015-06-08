//
//  ALCIntoVariable.h
//  alchemic
//
//  Created by Derek Clarkson on 7/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

@interface ALCIntoVariable : NSObject

@property (nonatomic, strong, readonly) NSString *variableName;

+(instancetype) intoVariableWithName:(NSString *) name;

@end

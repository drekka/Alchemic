//
//  ALCAsName.h
//  alchemic
//
//  Created by Derek Clarkson on 8/06/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/ALCMacroArgument.h>

@interface ALCAsName : NSObject<ALCMacroArgument>

@property (nonatomic, strong, readonly) NSString *asName;

+(instancetype) asNameWithName:(NSString *) name;

@end

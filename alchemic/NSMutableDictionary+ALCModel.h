//
//  NSDictionary+ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCInstance.h"

@interface NSMutableDictionary (ALCModel)

/**
 This does several things.
 If passed name is not the same as the class name then the call is coming from a class registration so we look for a current registration under the class name and shift it to the new name. Otherwise, if there is already an instance it is returned. Finally a new one is created and returned.
 */
-(ALCInstance *) objectDescriptionForClass:(Class) class name:(NSString *) name;

@end

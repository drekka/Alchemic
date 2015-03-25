//
//  NSDictionary+ALCModel.h
//  alchemic
//
//  Created by Derek Clarkson on 23/03/2015.
//  Copyright (c) 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;

#import "ALCObjectDescription.h"

@interface NSMutableDictionary (ALCModel)

-(ALCObjectDescription *) objectDescriptionForClass:(Class) forClass name:(NSString *) name;

-(void) registerInjection:(NSString *) inj inClass:(Class) class withName:(NSString *)name;

@end

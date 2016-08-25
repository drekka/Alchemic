//
//  ALCMapper.h
//  Alchemic
//
//  Created by Derek Clarkson on 25/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class ALCTypeData;

@interface ALCMapper : NSObject

-(BOOL) canMap:(ALCTypeData *) fromType toType:(ALCTypeData *) toType;

@end

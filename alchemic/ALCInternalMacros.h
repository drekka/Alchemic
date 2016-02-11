//
//  ALCInternalMacros.h
//  Alchemic
//
//  Created by Derek Clarkson on 12/02/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

#define str(template, ...) [NSString stringWithFormat:template, ## __VA_ARGS__ ]
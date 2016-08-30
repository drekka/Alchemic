//
//  ALCAbstractConstantValueSource.h
//  Alchemic
//
//  Created by Derek Clarkson on 30/8/16.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <Alchemic/ALCAbstractValueSource.h>

@interface ALCConstantValueSource : ALCAbstractValueSource

-(instancetype) initWithType:(ALCType *) type NS_UNAVAILABLE;

+(instancetype) valueSourceWithNil;

@end

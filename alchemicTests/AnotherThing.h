//
//  AnotherThing.h
//  Alchemic
//
//  Created by Derek Clarkson on 30/03/2016.
//  Copyright © 2016 Derek Clarkson. All rights reserved.
//

@import Foundation;

@class TopThing;

@interface AnotherThing : NSObject

@property (nonatomic, strong) TopThing *topThing;

-(instancetype) initWithTopThing:(TopThing *) aTopThing;

@end

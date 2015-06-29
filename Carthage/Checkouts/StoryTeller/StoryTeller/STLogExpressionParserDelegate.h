//
//  STLogExpressionParserDelegate.h
//  StoryTeller
//
//  Created by Derek Clarkson on 25/06/2015.
//  Copyright © 2015 Derek Clarkson. All rights reserved.
//

@import Foundation;
#import <PEGKit/PEGKit.h>

@protocol STLogExpressionParserDelegate <NSObject>

-(void) parser:(PKParser __nonnull *) parser didMatchClass:(PKAssembly __nonnull *) assembly;
-(void) parser:(PKParser __nonnull *) parser didMatchProtocol:(PKAssembly __nonnull *) assembly;

-(void) parser:(PKParser __nonnull *) parser didMatchKeyPath:(PKAssembly __nonnull *) assembly;

-(void) parser:(PKParser __nonnull *) parser didMatchLogicalExpression:(PKAssembly __nonnull *) assembly;
-(void) parser:(PKParser __nonnull *) parser didMatchMathExpression:(PKAssembly __nonnull *) assembly;
-(void) parser:(PKParser __nonnull *) parser didMatchSingleKey:(PKAssembly __nonnull *) assembly;

-(void) parser:(PKParser __nonnull *) parser didMatchBoolean:(PKAssembly __nonnull *) assembly;
-(void) parser:(PKParser __nonnull *) parser didMatchString:(PKAssembly __nonnull *) assembly;
-(void) parser:(PKParser __nonnull *) parser didMatchNumber:(PKAssembly __nonnull *) assembly;
-(void) parser:(PKParser __nonnull *) parser didMatchNil:(PKAssembly __nonnull *) assembly;

-(void) parser:(PKParser __nonnull *) parser didMatchIsa:(PKAssembly __nonnull *) assembly;
-(void) parser:(PKParser __nonnull *) parser didMatchLogAll:(PKAssembly __nonnull *) assembly;
-(void) parser:(PKParser __nonnull *) parser didMatchLogRoot:(PKAssembly __nonnull *) assembly;

@end

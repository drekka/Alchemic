#import "STLogExpressionParser.h"
#import <PEGKit/PEGKit.h>
    
#pragma GCC diagnostic ignored "-Wundeclared-selector"


@interface STLogExpressionParser ()

@end

@implementation STLogExpressionParser { }

- (instancetype)initWithDelegate:(id)d {
    self = [super initWithDelegate:d];
    if (self) {
        
        self.startRuleName = @"expr";
        self.tokenKindTab[@"false"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE);
        self.tokenKindTab[@">="] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_GE);
        self.tokenKindTab[@"LogRoots"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGROOT);
        self.tokenKindTab[@"=="] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ);
        self.tokenKindTab[@"<"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM);
        self.tokenKindTab[@"["] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET);
        self.tokenKindTab[@"true"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE);
        self.tokenKindTab[@"isa"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_ISA);
        self.tokenKindTab[@"LogAll"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGALL);
        self.tokenKindTab[@"."] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_DOT);
        self.tokenKindTab[@">"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM);
        self.tokenKindTab[@"]"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_CLOSE_BRACKET);
        self.tokenKindTab[@"nil"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_NIL);
        self.tokenKindTab[@"<="] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_LE);
        self.tokenKindTab[@"YES"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_YES_UPPER);
        self.tokenKindTab[@"!="] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_NE);
        self.tokenKindTab[@"NO"] = @(STLOGEXPRESSIONPARSER_TOKEN_KIND_NO_UPPER);

        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE] = @"false";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_GE] = @">=";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGROOT] = @"LogRoots";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ] = @"==";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM] = @"<";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET] = @"[";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE] = @"true";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_ISA] = @"isa";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGALL] = @"LogAll";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_DOT] = @".";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM] = @">";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_CLOSE_BRACKET] = @"]";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_NIL] = @"nil";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_LE] = @"<=";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_YES_UPPER] = @"YES";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_NE] = @"!=";
        self.tokenKindNameTab[STLOGEXPRESSIONPARSER_TOKEN_KIND_NO_UPPER] = @"NO";

    }
    return self;
}

- (void)start {

    [self expr_]; 
    [self matchEOF:YES]; 

}

- (void)expr_ {
    
    [self execute:^{
    
    PKTokenizer *t = self.tokenizer;
    [t.symbolState add:@"=="];
    [t.symbolState add:@"!="];
    [t.symbolState add:@"<="];
    [t.symbolState add:@">="];

    }];
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGALL, STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGROOT, 0]) {
        [self logControl_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_ISA, 0]) {
        [self runtimeExpr_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM, STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET, 0]) {
        [self classExpr_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self singleKey_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'expr'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchExpr:)];
}

- (void)singleKey_ {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_NUMBER, 0]) {
        [self number_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self string_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'singleKey'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchSingleKey:)];
}

- (void)classExpr_ {
    
    [self runtimeType_]; 
    if ([self speculate:^{ [self keyPath_]; if ([self speculate:^{ [self logicalExpression_]; }]) {[self logicalExpression_]; } else if ([self speculate:^{ [self mathExpression_]; }]) {[self mathExpression_]; } else {[self raise:@"No viable alternative found in rule 'classExpr'."];}}]) {
        [self keyPath_]; 
        if ([self speculate:^{ [self logicalExpression_]; }]) {
            [self logicalExpression_]; 
        } else if ([self speculate:^{ [self mathExpression_]; }]) {
            [self mathExpression_]; 
        } else {
            [self raise:@"No viable alternative found in rule 'classExpr'."];
        }
    }

    [self fireDelegateSelector:@selector(parser:didMatchClassExpr:)];
}

- (void)logicalExpression_ {
    
    [self logicalOp_]; 
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE, STLOGEXPRESSIONPARSER_TOKEN_KIND_NO_UPPER, STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE, STLOGEXPRESSIONPARSER_TOKEN_KIND_YES_UPPER, 0]) {
        [self boolean_]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self string_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_NIL, 0]) {
        [self nil_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'logicalExpression'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchLogicalExpression:)];
}

- (void)mathExpression_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ, STLOGEXPRESSIONPARSER_TOKEN_KIND_NE, 0]) {
        [self logicalOp_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_GE, STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM, STLOGEXPRESSIONPARSER_TOKEN_KIND_LE, STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM, 0]) {
        [self mathOp_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'mathExpression'."];
    }
    [self number_]; 

    [self fireDelegateSelector:@selector(parser:didMatchMathExpression:)];
}

- (void)logControl_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGALL, 0]) {
        [self logAll_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGROOT, 0]) {
        [self logRoot_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'logControl'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchLogControl:)];
}

- (void)logAll_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGALL discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchLogAll:)];
}

- (void)logRoot_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_LOGROOT discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchLogRoot:)];
}

- (void)runtimeExpr_ {
    
    [self isa_]; 
    [self runtimeType_]; 

    [self fireDelegateSelector:@selector(parser:didMatchRuntimeExpr:)];
}

- (void)runtimeType_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET, 0]) {
        [self class_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM, 0]) {
        [self protocol_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'runtimeType'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchRuntimeType:)];
}

- (void)isa_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_ISA discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchIsa:)];
}

- (void)keyPath_ {
    
    do {
        [self propertyPath_]; 
    } while ([self speculate:^{ [self propertyPath_]; }]);

    [self fireDelegateSelector:@selector(parser:didMatchKeyPath:)];
}

- (void)propertyPath_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_DOT discard:YES]; 
    [self propertyName_]; 

    [self fireDelegateSelector:@selector(parser:didMatchPropertyPath:)];
}

- (void)propertyName_ {
    
    [self testAndThrow:(id)^{ return islower([LS(1) characterAtIndex:0]); }]; 
    [self matchWord:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchPropertyName:)];
}

- (void)protocol_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM discard:YES]; 
    [self objCId_]; 
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM discard:YES]; 

    [self fireDelegateSelector:@selector(parser:didMatchProtocol:)];
}

- (void)class_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_OPEN_BRACKET discard:YES]; 
    [self objCId_]; 
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_CLOSE_BRACKET discard:YES]; 

    [self fireDelegateSelector:@selector(parser:didMatchClass:)];
}

- (void)objCId_ {
    
    [self testAndThrow:(id)^{ return isupper([LS(1) characterAtIndex:0]); }]; 
    [self matchWord:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchObjCId:)];
}

- (void)string_ {
    
    if ([self predicts:TOKEN_KIND_BUILTIN_WORD, 0]) {
        [self matchWord:NO]; 
    } else if ([self predicts:TOKEN_KIND_BUILTIN_QUOTEDSTRING, 0]) {
        [self matchQuotedString:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'string'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchString:)];
}

- (void)number_ {
    
    [self matchNumber:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchNumber:)];
}

- (void)boolean_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_YES_UPPER, 0]) {
        [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_YES_UPPER discard:NO]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE, 0]) {
        [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_TRUE discard:NO]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_NO_UPPER, 0]) {
        [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_NO_UPPER discard:NO]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE, 0]) {
        [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_FALSE discard:NO]; 
    } else {
        [self raise:@"No viable alternative found in rule 'boolean'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchBoolean:)];
}

- (void)nil_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_NIL discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchNil:)];
}

- (void)mathOp_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM, 0]) {
        [self lt_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM, 0]) {
        [self gt_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_LE, 0]) {
        [self le_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_GE, 0]) {
        [self ge_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'mathOp'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchMathOp:)];
}

- (void)logicalOp_ {
    
    if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ, 0]) {
        [self eq_]; 
    } else if ([self predicts:STLOGEXPRESSIONPARSER_TOKEN_KIND_NE, 0]) {
        [self ne_]; 
    } else {
        [self raise:@"No viable alternative found in rule 'logicalOp'."];
    }

    [self fireDelegateSelector:@selector(parser:didMatchLogicalOp:)];
}

- (void)lt_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_LT_SYM discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchLt:)];
}

- (void)gt_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_GT_SYM discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchGt:)];
}

- (void)eq_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_EQ discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchEq:)];
}

- (void)ne_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_NE discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchNe:)];
}

- (void)le_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_LE discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchLe:)];
}

- (void)ge_ {
    
    [self match:STLOGEXPRESSIONPARSER_TOKEN_KIND_GE discard:NO]; 

    [self fireDelegateSelector:@selector(parser:didMatchGe:)];
}

@end
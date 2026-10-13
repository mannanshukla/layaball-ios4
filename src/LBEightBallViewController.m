#import "LBEightBallViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation LBBallView
@synthesize answer, window;
- (void)dealloc { [answer release]; [super dealloc]; }
- (void)setAnswer:(NSString *)a { [answer release]; answer = [a copy]; [self setNeedsDisplay]; }
- (void)setWindow:(CGFloat)w { window = w; [self setNeedsDisplay]; }
- (id)initWithFrame:(CGRect)f { if ((self = [super initWithFrame:f])) { self.backgroundColor = [UIColor clearColor]; self.opaque = NO; self.contentMode = UIViewContentModeRedraw; } return self; }
- (void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGFloat d = MIN(self.bounds.size.width, self.bounds.size.height) - 8, cx = self.bounds.size.width/2, cy = self.bounds.size.height/2;
    CGRect sphere = CGRectMake(cx - d/2, cy - d/2, d, d);
    // drop shadow
    CGContextSaveGState(ctx);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 6), 10, [UIColor colorWithWhite:0 alpha:0.45].CGColor);
    [[UIColor blackColor] setFill]; [[UIBezierPath bezierPathWithOvalInRect:sphere] fill];
    CGContextRestoreGState(ctx);
    // glossy black sphere
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGFloat c[12] = {0.36,0.36,0.38,1, 0.10,0.10,0.11,1, 0.0,0.0,0.0,1};
    CGGradientRef g = CGGradientCreateWithColorComponents(cs, c, NULL, 3);
    CGContextSaveGState(ctx); [[UIBezierPath bezierPathWithOvalInRect:sphere] addClip];
    CGContextDrawRadialGradient(ctx, g, CGPointMake(cx - d*0.25, cy - d*0.30), 0, CGPointMake(cx, cy), d*0.62, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(g);
    // window: dark blue circle with the triangle
    CGFloat wd = d*0.52; CGRect win = CGRectMake(cx - wd/2, cy - wd/2 + d*0.04, wd, wd);
    CGFloat wc[8] = {0.02,0.05,0.25,1, 0.0,0.0,0.08,1};
    CGGradientRef wg = CGGradientCreateWithColorComponents(cs, wc, NULL, 2);
    CGContextSaveGState(ctx); [[UIBezierPath bezierPathWithOvalInRect:win] addClip];
    CGContextDrawLinearGradient(ctx, wg, CGPointMake(0, win.origin.y), CGPointMake(0, CGRectGetMaxY(win)), 0);
    CGGradientRelease(wg);
    // triangle rising into view as `window` goes 0 -> 1
    CGFloat tri = wd*0.86, rise = (1 - window) * wd*0.9;
    CGPoint tc = CGPointMake(cx, CGRectGetMidY(win) + rise);
    UIBezierPath *t = [UIBezierPath bezierPath];
    [t moveToPoint:CGPointMake(tc.x, tc.y - tri*0.55)]; [t addLineToPoint:CGPointMake(tc.x + tri*0.5, tc.y + tri*0.33)]; [t addLineToPoint:CGPointMake(tc.x - tri*0.5, tc.y + tri*0.33)]; [t closePath];
    [[UIColor colorWithRed:0.10 green:0.22 blue:0.70 alpha:1] setFill]; [t fill];
    [[UIColor colorWithRed:0.35 green:0.50 blue:0.95 alpha:0.9] setStroke]; t.lineWidth = 1.5; [t stroke];
    if ([answer length] && window > 0.05) {
        UIFont *f = [UIFont boldSystemFontOfSize:13];
        CGRect tr = CGRectMake(tc.x - tri*0.36, tc.y - tri*0.22, tri*0.72, tri*0.5);
        [[UIColor colorWithWhite:1 alpha:MIN(1, window*1.2)] set];
        [[answer uppercaseString] drawInRect:tr withFont:f lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
    }
    CGContextRestoreGState(ctx);
    [[UIColor colorWithWhite:0 alpha:0.6] setStroke]; [[UIBezierPath bezierPathWithOvalInRect:win] stroke];
    // specular highlight
    CGFloat hc[8] = {1,1,1,0.55, 1,1,1,0.0};
    CGGradientRef hg = CGGradientCreateWithColorComponents(cs, hc, NULL, 2);
    CGRect hi = CGRectMake(cx - d*0.34, cy - d*0.44, d*0.42, d*0.26);
    CGContextSaveGState(ctx); [[UIBezierPath bezierPathWithOvalInRect:hi] addClip];
    CGContextDrawLinearGradient(ctx, hg, CGPointMake(0, hi.origin.y), CGPointMake(0, CGRectGetMaxY(hi)), 0);
    CGContextRestoreGState(ctx);
    CGGradientRelease(hg); CGColorSpaceRelease(cs);
    CGContextRestoreGState(ctx);
}
@end

@implementation LBEightBallViewController
- (id)init { if ((self = [super initWithNibName:nil bundle:nil])) { self.title = @"8-Ball"; self.tabBarItem.title = @"8-Ball"; } return self; }
- (void)dealloc { [question release]; [ball release]; [detail release]; [spinner release]; [super dealloc]; }
- (void)loadView {
    UIView *root = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    root.backgroundColor = [LBStyle paper]; self.view = root; [root release];
    CGRect b = root.bounds;
    question = [[UITextField alloc] initWithFrame:CGRectMake(12, 12, b.size.width - 24, 34)];
    question.borderStyle = UITextBorderStyleRoundedRect; question.placeholder = @"Ask a yes or no question";
    question.font = [UIFont systemFontOfSize:16]; question.returnKeyType = UIReturnKeyDone; question.delegate = self;
    question.autocapitalizationType = UITextAutocapitalizationTypeSentences; question.clearButtonMode = UITextFieldViewModeWhileEditing;
    question.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [root addSubview:question];
    CGFloat bd = MIN(b.size.width - 60, b.size.height - 60 - 70);
    ball = [[LBBallView alloc] initWithFrame:CGRectMake((b.size.width - bd)/2, 54, bd, bd)];
    [root addSubview:ball];
    detail = [[UILabel alloc] initWithFrame:CGRectMake(12, 54 + bd + 2, b.size.width - 24, 40)];
    detail.font = [UIFont systemFontOfSize:14]; detail.textColor = [UIColor colorWithWhite:0.4 alpha:1]; detail.textAlignment = UITextAlignmentCenter;
    detail.numberOfLines = 2; detail.backgroundColor = [UIColor clearColor]; detail.text = @"Type a question, then shake.";
    [root addSubview:detail];
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.center = CGPointMake(b.size.width/2, CGRectGetMaxY(detail.frame) + 10); spinner.hidesWhenStopped = YES;
    question.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"lb_question"];
    [root addSubview:spinner];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Shake" style:UIBarButtonItemStyleBordered target:self action:@selector(shaken)] autorelease];
}
- (BOOL)textFieldShouldReturn:(UITextField *)tf { [tf resignFirstResponder]; return YES; }
- (void)textFieldDidEndEditing:(UITextField *)tf { [[NSUserDefaults standardUserDefaults] setObject:tf.text ?: @"" forKey:@"lb_question"]; [[NSUserDefaults standardUserDefaults] synchronize]; }
- (NSString *)answerFor:(double)p confidence:(double)conf {
    NSArray *pick;
    if (conf < 0.42) pick = [NSArray arrayWithObjects:@"Reply hazy, try again", @"Ask again later", @"Cannot predict now", @"Concentrate and ask again", @"Better not tell you now", nil];
    else if (p >= 0.80) pick = [NSArray arrayWithObjects:@"It is certain", @"It is decidedly so", @"Without a doubt", @"Yes, definitely", @"You may rely on it", nil];
    else if (p >= 0.60) pick = [NSArray arrayWithObjects:@"As I see it, yes", @"Most likely", @"Outlook good", @"Signs point to yes", @"Yes", nil];
    else if (p >= 0.45) pick = [NSArray arrayWithObjects:@"Reply hazy, try again", @"Ask again later", @"Cannot predict now", nil];
    else if (p >= 0.25) pick = [NSArray arrayWithObjects:@"Don't count on it", @"Outlook not so good", @"Very doubtful", nil];
    else pick = [NSArray arrayWithObjects:@"My reply is no", @"My sources say no", @"Don't count on it", @"Very doubtful", nil];
    return [pick objectAtIndex:arc4random() % [pick count]];
}
- (void)shaken {
    if (busy) return;
    NSString *q = [question.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [question resignFirstResponder];
    if (![q length]) { detail.text = @"Ask something first."; return; }
    busy = YES; [spinner startAnimating]; detail.text = @"";
    // wobble + blank the window
    CAKeyframeAnimation *wob = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    wob.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:-0.18], [NSNumber numberWithFloat:0.16], [NSNumber numberWithFloat:-0.12], [NSNumber numberWithFloat:0.08], [NSNumber numberWithFloat:0], nil];
    wob.duration = 0.7; [ball.layer addAnimation:wob forKey:@"wobble"];
    ball.window = 0;
    __block NSDictionary *ans = nil; __block NSString *err = nil;
    [self runOffMain:^{ NSString *e = nil; ans = [[LBLaya yesNo:q error:&e] retain]; err = [e copy]; } then:^{
        busy = NO; [spinner stopAnimating];
        if (!ans) { detail.text = err ?: @"No answer."; ball.answer = @"Try again"; [self reveal]; [err release]; return; }
        double p = [[ans objectForKey:@"noul"] doubleValue], conf = [[ans objectForKey:@"confidence"] doubleValue];
        ball.answer = [self answerFor:p confidence:conf];
        detail.text = [NSString stringWithFormat:@"Laya says %d%% yes\nconfidence %d%%", (int)(p*100 + 0.5), (int)(conf*100 + 0.5)];
        [self reveal]; [ans release]; [err release];
    }];
}
- (void)reveal { [self animateWindowTo:1 step:0]; }
- (void)animateWindowTo:(CGFloat)target step:(int)i {
    ball.window = MIN(1, i / 12.0);
    if (i < 12) [self performSelector:@selector(animateStep:) withObject:[NSNumber numberWithInt:i+1] afterDelay:0.045];
}
- (void)animateStep:(NSNumber *)n { [self animateWindowTo:1 step:[n intValue]]; }
@end

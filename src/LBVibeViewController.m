#import "LBVibeViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation LBMeterView
- (id)initWithFrame:(CGRect)f { if ((self = [super initWithFrame:f])) { self.backgroundColor = [UIColor clearColor]; self.opaque = NO; score = -1; } return self; }
- (void)dealloc { [levels release]; [probs release]; [super dealloc]; }
- (void)setScore:(double)s levels:(NSArray *)l probs:(NSDictionary *)p { score = s; [levels release]; levels = [l retain]; [probs release]; probs = [p retain]; [self setNeedsDisplay]; }
- (void)drawRect:(CGRect)rect {
    CGFloat w = self.bounds.size.width, trackY = 18, trackH = 18;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    CGFloat c[16] = {0.62,0.84,0.20,1, 0.95,0.85,0.25,1, 0.95,0.55,0.20,1, 0.85,0.20,0.15,1};
    CGGradientRef g = CGGradientCreateWithColorComponents(cs, c, NULL, 4);
    CGContextSaveGState(ctx);
    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, trackY, w, trackH) cornerRadius:9] addClip];
    CGContextDrawLinearGradient(ctx, g, CGPointMake(0, 0), CGPointMake(w, 0), 0);
    CGContextRestoreGState(ctx); CGGradientRelease(g); CGColorSpaceRelease(cs);
    [[UIColor colorWithWhite:0 alpha:0.25] setStroke]; [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0.5, trackY+0.5, w-1, trackH-1) cornerRadius:9] stroke];
    if (score >= 0 && [levels count] > 1) {
        CGFloat x = w * (score / ([levels count] - 1));
        UIBezierPath *needle = [UIBezierPath bezierPath];
        [needle moveToPoint:CGPointMake(x, trackY - 2)]; [needle addLineToPoint:CGPointMake(x - 7, trackY - 14)]; [needle addLineToPoint:CGPointMake(x + 7, trackY - 14)]; [needle closePath];
        [[UIColor blackColor] setFill]; [needle fill];
        UIFont *f = [UIFont boldSystemFontOfSize:11];
        CGFloat seg = w / [levels count];
        for (NSUInteger i = 0; i < [levels count]; i++) {
            [[UIColor colorWithWhite:0.3 alpha:1] set];
            [[levels objectAtIndex:i] drawInRect:CGRectMake(i*seg, trackY + trackH + 6, seg, 30) withFont:f lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentCenter];
        }
    }
}
@end

@implementation LBVibeViewController
- (id)init { if ((self = [super initWithNibName:nil bundle:nil])) { self.title = @"Vibe Check"; self.tabBarItem.title = @"Vibe"; } return self; }
- (void)dealloc { [draft release]; [meter release]; [verdict release]; [extra release]; [super dealloc]; }
- (void)loadView {
    UIView *root = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    root.backgroundColor = [LBStyle paper]; self.view = root; [root release];
    CGRect b = root.bounds;
    UILabel *l = [[[UILabel alloc] initWithFrame:CGRectMake(12, 8, b.size.width - 24, 20)] autorelease];
    l.text = @"Paste the text you're about to send:"; l.font = [UIFont systemFontOfSize:13]; l.textColor = [UIColor colorWithWhite:0.4 alpha:1]; l.backgroundColor = [UIColor clearColor];
    [root addSubview:l];
    draft = [[UITextView alloc] initWithFrame:CGRectMake(12, 30, b.size.width - 24, 110)];
    draft.font = [UIFont systemFontOfSize:15]; draft.layer.borderColor = [UIColor colorWithWhite:0.7 alpha:1].CGColor; draft.layer.borderWidth = 1; draft.layer.cornerRadius = 6; draft.delegate = self;
    draft.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"lb_draft"] ?: @"";
    [root addSubview:draft];
    verdict = [[UILabel alloc] initWithFrame:CGRectMake(12, 150, b.size.width - 24, 30)];
    verdict.font = [UIFont boldSystemFontOfSize:22]; verdict.textAlignment = UITextAlignmentCenter; verdict.backgroundColor = [UIColor clearColor]; verdict.textColor = [LBStyle olive]; verdict.text = @"Shake to check"; verdict.adjustsFontSizeToFitWidth = YES;
    [root addSubview:verdict];
    meter = [[LBMeterView alloc] initWithFrame:CGRectMake(16, 188, b.size.width - 32, 80)];
    [root addSubview:meter];
    extra = [[UILabel alloc] initWithFrame:CGRectMake(12, 272, b.size.width - 24, 60)];
    extra.font = [UIFont systemFontOfSize:14]; extra.textAlignment = UITextAlignmentCenter; extra.numberOfLines = 3; extra.backgroundColor = [UIColor clearColor]; extra.textColor = [UIColor colorWithWhite:0.35 alpha:1];
    [root addSubview:extra];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Shake" style:UIBarButtonItemStyleBordered target:self action:@selector(shaken)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(dismissKeyboard)] autorelease];
}
- (void)dismissKeyboard { [draft resignFirstResponder]; }
- (void)textViewDidEndEditing:(UITextView *)tv { [[NSUserDefaults standardUserDefaults] setObject:tv.text forKey:@"lb_draft"]; [[NSUserDefaults standardUserDefaults] synchronize]; }
- (void)shaken {
    if (busy) return;
    NSString *t = [draft.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [draft resignFirstResponder];
    if (![t length]) { verdict.text = @"Paste something first"; return; }
    busy = YES; verdict.text = @"Reading the room..."; extra.text = @"";
    NSArray *levels = [NSArray arrayWithObjects:@"genuinely fine", @"a little pointed", @"passive-aggressive", @"openly angry", nil];
    NSString *state = [NSString stringWithFormat:@"Draft text message the user is about to send: \"%@\"", t];
    NSDictionary *qs = [NSDictionary dictionaryWithObjectsAndKeys:
        [NSDictionary dictionaryWithObjectsAndKeys:@"score", @"type", @"How passive-aggressive does this message sound to the person receiving it?", @"instructions", levels, @"criteria", nil], @"tone",
        [NSDictionary dictionaryWithObjectsAndKeys:@"noul", @"type", @"Would a reasonable person feel hurt or annoyed reading this?", @"instructions", nil], @"hurt",
        [NSDictionary dictionaryWithObjectsAndKeys:@"noul", @"type", @"Is this message clear about what the sender actually wants?", @"instructions", nil], @"clear",
        nil];
    __block NSDictionary *ans = nil; __block NSString *err = nil;
    [self runOffMain:^{ NSString *e = nil; ans = [[LBLaya decide:state questions:qs error:&e] retain]; err = [e copy]; } then:^{
        busy = NO;
        if (!ans) { verdict.text = err ?: @"No answer"; [err release]; return; }
        NSDictionary *tone = [ans objectForKey:@"tone"];
        double s = [[tone objectForKey:@"score"] doubleValue];
        NSInteger idx = (NSInteger)(s + 0.5); if (idx < 0) idx = 0; if (idx > 3) idx = 3;
        NSArray *verdicts = [NSArray arrayWithObjects:@"Send it", @"Hmm, a little pointed", @"That's passive-aggressive", @"Do not send that", nil];
        verdict.text = [verdicts objectAtIndex:idx];
        verdict.textColor = idx == 0 ? [LBStyle olive] : idx == 3 ? [UIColor colorWithRed:0.75 green:0.15 blue:0.1 alpha:1] : [UIColor colorWithRed:0.75 green:0.45 blue:0.05 alpha:1];
        [meter setScore:s levels:levels probs:[tone objectForKey:@"probabilities"]];
        double hurt = [[[ans objectForKey:@"hurt"] objectForKey:@"noul"] doubleValue], clear = [[[ans objectForKey:@"clear"] objectForKey:@"noul"] doubleValue];
        extra.text = [NSString stringWithFormat:@"%d%% chance it lands wrong\n%d%% clear about what you want", (int)(hurt*100+0.5), (int)(clear*100+0.5)];
        [ans release]; [err release];
    }];
}
@end

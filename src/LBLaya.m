#import "LBLaya.h"
#import "ORJSON.h"

@implementation LBLaya
+ (NSString *)apiKey { return [[NSUserDefaults standardUserDefaults] stringForKey:@"lb_api_key"] ?: @""; }
+ (void)setApiKey:(NSString *)k { [[NSUserDefaults standardUserDefaults] setObject:k forKey:@"lb_api_key"]; [[NSUserDefaults standardUserDefaults] synchronize]; }

+ (NSDictionary *)decide:(id)state questions:(NSDictionary *)questions error:(NSString **)err {
    if (![[self apiKey] length]) { if (err) *err = @"No API key. Add it in Settings."; return nil; }
    NSDictionary *body = [NSDictionary dictionaryWithObjectsAndKeys:@"openrelay/laya", @"model", state, @"state", questions, @"questions", nil];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://inference.openrelay.inc/v1/decisions"] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [req setValue:[NSString stringWithFormat:@"Bearer %@", [self apiKey]] forHTTPHeaderField:@"Authorization"];
    [req setValue:@"close" forHTTPHeaderField:@"Connection"];
    [req setHTTPBody:[[ORJSON stringify:body] dataUsingEncoding:NSUTF8StringEncoding]];
    NSHTTPURLResponse *resp = nil; NSError *e = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req returningResponse:&resp error:&e];
    if (!data) { if (err) *err = [e localizedDescription]; return nil; }
    id obj = [ORJSON parse:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
    if ([resp statusCode] != 200 || ![obj isKindOfClass:[NSDictionary class]]) {
        NSString *m = [NSString stringWithFormat:@"HTTP %d", (int)[resp statusCode]];
        id er = [obj isKindOfClass:[NSDictionary class]] ? [obj objectForKey:@"error"] : nil;
        if ([er isKindOfClass:[NSDictionary class]] && [er objectForKey:@"message"]) m = [er objectForKey:@"message"];
        if (err) *err = m; return nil;
    }
    return [obj objectForKey:@"answers"];
}
+ (NSDictionary *)yesNo:(NSString *)question error:(NSString **)err {
    NSDictionary *q = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"noul", @"type",
        @"Is the honest answer to the user's question yes?", @"instructions",
        [NSDictionary dictionaryWithObjectsAndKeys:@"the honest answer is yes", @"true", @"the honest answer is no", @"false", nil], @"criteria", nil] forKey:@"a"];
    NSDictionary *a = [self decide:question questions:q error:err];
    return [a objectForKey:@"a"];
}
+ (NSDictionary *)choose:(NSString *)instructions among:(NSArray *)labels state:(NSString *)state error:(NSString **)err {
    NSDictionary *q = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"choice", @"type", instructions, @"instructions", labels, @"criteria", nil] forKey:@"a"];
    return [[self decide:state questions:q error:err] objectForKey:@"a"];
}
+ (NSDictionary *)score:(NSString *)instructions levels:(NSArray *)levels state:(NSString *)state error:(NSString **)err {
    NSDictionary *q = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObjectsAndKeys:@"score", @"type", instructions, @"instructions", levels, @"criteria", nil] forKey:@"a"];
    return [[self decide:state questions:q error:err] objectForKey:@"a"];
}
@end

@implementation LBShakeViewController
- (BOOL)canBecomeFirstResponder { return YES; }
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    if ([d boolForKey:@"lb_test_shake"]) { [d removeObjectForKey:@"lb_test_shake"]; [d synchronize]; [self performSelector:@selector(shaken) withObject:nil afterDelay:0.6]; }
}
- (void)viewWillDisappear:(BOOL)animated { [self resignFirstResponder]; [super viewWillDisappear:animated]; }
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event { if (motion == UIEventSubtypeMotionShake) [self shaken]; }
- (void)shaken {}
- (void)runOffMain:(void (^)(void))work then:(void (^)(void))done {
    work = [work copy]; done = [done copy];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        work();
        dispatch_async(dispatch_get_main_queue(), ^{ done(); [work release]; [done release]; });
    });
}
@end

@implementation LBStyle
+ (UIColor *)lime { return [UIColor colorWithRed:0xAF/255.0 green:0xE2/255.0 blue:0x04/255.0 alpha:1]; }
+ (UIColor *)olive { return [UIColor colorWithRed:0x14/255.0 green:0x8C/255.0 blue:0x7E/255.0 alpha:1]; }
+ (UIColor *)paper { return [UIColor colorWithRed:0.95 green:0.95 blue:0.93 alpha:1]; }
+ (UIImage *)buttonImage:(UIColor *)top bottom:(UIColor *)bottom border:(UIColor *)border {
    CGSize sz = CGSizeMake(40, 40);
    UIGraphicsBeginImageContextWithOptions(sz, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect r = CGRectMake(0.5, 0.5, sz.width-1, sz.height-1);
    UIBezierPath *p = [UIBezierPath bezierPathWithRoundedRect:r cornerRadius:8];
    CGContextSaveGState(ctx); [p addClip];
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceRGB();
    const CGFloat *t = CGColorGetComponents(top.CGColor), *b = CGColorGetComponents(bottom.CGColor);
    CGFloat c[8] = {t[0],t[1],t[2],1, b[0],b[1],b[2],1};
    CGGradientRef g = CGGradientCreateWithColorComponents(cs, c, NULL, 2);
    CGContextDrawLinearGradient(ctx, g, CGPointMake(0,0), CGPointMake(0,sz.height), 0);
    CGGradientRelease(g);
    CGFloat gl[8] = {1,1,1,0.45, 1,1,1,0.05};
    CGGradientRef g2 = CGGradientCreateWithColorComponents(cs, gl, NULL, 2);
    CGContextDrawLinearGradient(ctx, g2, CGPointMake(0,0), CGPointMake(0,sz.height/2), 0);
    CGGradientRelease(g2); CGColorSpaceRelease(cs);
    CGContextRestoreGState(ctx);
    [border setStroke]; p.lineWidth = 1; [p stroke];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return [img stretchableImageWithLeftCapWidth:10 topCapHeight:19];
}
@end

#import <UIKit/UIKit.h>
#import "LBLaya.h"
#import "LBEightBallViewController.h"
#import "LBDecideViewController.h"
#import "LBRPSViewController.h"
#import "LBVibeViewController.h"

@interface LBAppDelegate : NSObject <UIApplicationDelegate> { UIWindow *window; UITabBarController *tabs; }
@end
@implementation LBAppDelegate
- (UINavigationController *)wrap:(UIViewController *)vc {
    UINavigationController *n = [[[UINavigationController alloc] initWithRootViewController:vc] autorelease];
    n.navigationBar.tintColor = [LBStyle olive];
    return n;
}
- (void)needKey { UIAlertView *a = [[UIAlertView alloc] initWithTitle:@"Add your OpenRelay key" message:@"Open the Settings app, scroll to Laya Ball, and paste your API key. Every shake is one call to Laya." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]; [a show]; [a release]; }
- (BOOL)application:(UIApplication *)app didFinishLaunchingWithOptions:(NSDictionary *)opts {
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    tabs = [[UITabBarController alloc] init];
    LBEightBallViewController *ball = [[[LBEightBallViewController alloc] init] autorelease];
    LBDecideViewController *decide = [[[LBDecideViewController alloc] init] autorelease];
    LBRPSViewController *rps = [[[LBRPSViewController alloc] init] autorelease];
    LBVibeViewController *vibe = [[[LBVibeViewController alloc] init] autorelease];
    ball.tabBarItem.image = [UIImage imageNamed:@"tab-ball.png"]; decide.tabBarItem.image = [UIImage imageNamed:@"tab-decide.png"];
    rps.tabBarItem.image = [UIImage imageNamed:@"tab-rps.png"]; vibe.tabBarItem.image = [UIImage imageNamed:@"tab-vibe.png"];
    tabs.viewControllers = [NSArray arrayWithObjects:[self wrap:ball], [self wrap:decide], [self wrap:rps], [self wrap:vibe], nil];
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    tabs.selectedIndex = [d integerForKey:@"lb_tab"];
    [window addSubview:tabs.view];
    [window makeKeyAndVisible];
    if (![[LBLaya apiKey] length]) [self performSelector:@selector(needKey) withObject:nil afterDelay:0.6];
    return YES;
}
- (void)applicationWillTerminate:(UIApplication *)app { [[NSUserDefaults standardUserDefaults] setInteger:tabs.selectedIndex forKey:@"lb_tab"]; [[NSUserDefaults standardUserDefaults] synchronize]; }
- (void)dealloc { [tabs release]; [window release]; [super dealloc]; }
@end

int main(int argc, char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int r = UIApplicationMain(argc, argv, nil, @"LBAppDelegate");
    [pool release];
    return r;
}

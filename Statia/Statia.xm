#import <UIKit/UIKit.h>
#import <SIAlertView.h>
#import <notify.h>

#define TEST_UIAPPEARANCE 0

#if TEST_UIAPPEARANCE
[[SIAlertView appearance] setMessageFont:[UIFont systemFontOfSize:13]];
[[SIAlertView appearance] setTitleColor:[UIColor greenColor]];
[[SIAlertView appearance] setMessageColor:[UIColor purpleColor]];
[[SIAlertView appearance] setCornerRadius:12];
[[SIAlertView appearance] setShadowRadius:20];
[[SIAlertView appearance] setViewBackgroundColor:[UIColor colorWithRed:0.891 green:0.936 blue:0.978 alpha:1.000]];
#endif

static UIAlertView *alert;
static UILongPressGestureRecognizer *longPressGR;
static UIButton *longpressButton;

@interface SBAppSliderController : UIViewController
        
- (NSArray *)applicationList;
- (void)_quitAppAtIndex:(unsigned int)arg1;
- (UIScrollView *)pageForDisplayIdentifier:(id)arg1;
- (void)forceDismissAnimated:(BOOL)arg1;
        
@end


@interface SBApplication: NSObject

-(id)bundleIdentifier;

@end



@interface SpringBoard : UIApplication

- (SBApplication *)nowPlayingApp;
-(void)powerDown;
-(void)reboot;

@end


@class UIWindow, SBAppSliderWindow;

@interface SBAppSliderWindowController : NSObject {
    
    SBAppSliderWindow* _window;
	UIViewController* _rootViewController;
}

-(id)initWithRootViewController:(id)rootViewController;

@property(readonly, assign, nonatomic) UIWindow* window;
@property(retain, nonatomic) UIViewController* rootViewController;
@end





%hook SBAppSliderController

- (void)switcherWasPresented:(_Bool)arg1
{
		longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(quitAll)];
//长按1秒后触发事件
		longPressGR.minimumPressDuration = 0.8;
		[self.view addGestureRecognizer:longPressGR];
    %orig;
}

- (BOOL)sliderScroller:(id)arg1 isIndexRemovable:(unsigned int)arg2 {
        return YES;
}

- (void)_quitAppAtIndex:(unsigned int)arg1 {
      if (arg1 == 0) {
          
          
          SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Statia" andMessage:@"Choose an option"];
          [alertView addButtonWithTitle:@"Respring"
                                   type:SIAlertViewButtonTypeDefault
                                handler:^(SIAlertView *alertView) {
                                    system("killall backboardd");
                                }];
          [alertView addButtonWithTitle:@"Power Off"
                                   type:SIAlertViewButtonTypeDefault
                                handler:^(SIAlertView *alertView) {
                                    [(SpringBoard *)[UIApplication sharedApplication] powerDown];
                                }];
          [alertView addButtonWithTitle:@"Reboot"
                                   type:SIAlertViewButtonTypeDefault
                                handler:^(SIAlertView *alertView) {
                                    [(SpringBoard *)[UIApplication sharedApplication] reboot];
                                }];
          [alertView addButtonWithTitle:@"Cancel"
                                   type:SIAlertViewButtonTypeDestructive
                                handler:^(SIAlertView *alertView) {
                                    UIScrollView *SpringBoardPage = (UIScrollView *)[[self pageForDisplayIdentifier:@"com.apple.springboard"] superview];
                                    
                                    [SpringBoardPage setContentOffset:CGPointMake(0, 0) animated:YES];
                                    
                                    [UIView animateWithDuration:0.9f animations:^(void) { }];
                                }];
          
          alertView.willShowHandler = ^(SIAlertView *alertView) {
              NSLog(@"%@, willShowHandler", alertView);
          };
          alertView.didShowHandler = ^(SIAlertView *alertView) {
              NSLog(@"%@, didShowHandler", alertView);
          };
          alertView.willDismissHandler = ^(SIAlertView *alertView) {
              NSLog(@"%@, willDismissHandler", alertView);
          };
          alertView.didDismissHandler = ^(SIAlertView *alertView) {
              NSLog(@"%@, didDismissHandler", alertView);
          };
          

          [alertView show];
          

      }
      else
              %orig;
}
- (void)switcherWillBeDismissed:(BOOL)switcher {
    [self.view removeGestureRecognizer:longPressGR];
    %orig;
}




%new
- (void)quitAll{
        NSString *nowPlayingAppID = [[(SpringBoard *)[UIApplication sharedApplication] nowPlayingApp] bundleIdentifier];
		for (NSString *appID in [self applicationList]) {
        if (![appID isEqualToString:@"com.apple.springboard"]&&![appID isEqualToString:nowPlayingAppID])
        {
                UIScrollView *appPage = (UIScrollView *)[[self pageForDisplayIdentifier:appID] superview];
    
                //[appPage setContentOffset:CGPointMake(0, self.view.frame.size.height) animated:YES];
             
                [UIView animateWithDuration:0.4f animations:^{
                    appPage.alpha = 0;
                } completion:^(BOOL finished) {
                    [self _quitAppAtIndex:[[self applicationList] indexOfObject:appID]];
                }];
        }
		//[self forceDismissAnimated:YES];
    }
}
%end

%hook SBAppSliderWindowController

-(id)initWithRootViewController:(id)rootViewController {
    UIViewController *rootVC = (UIViewController *)rootViewController;
    
    UIView *parentView = [[UIView alloc] initWithFrame:CGRectMake(0, 150, 320, 200)];
    parentView.backgroundColor = [UIColor yellowColor];
    parentView.tag = 1000;
    [rootVC.view addSubview:parentView];
    %orig((id)rootVC);
    return %orig((id)rootVC);
}


%end





#import <UIKit/UIKit.h>
#import <SIAlertView.h>
#import <notify.h>
#import <UIViewController+CWPopup.h>

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
static UIViewController *rootVC;
static UIView *parentView;

@interface SBAppSliderController : UIViewController
        
- (NSArray *)applicationList;
- (void)_quitAppAtIndex:(unsigned int)arg1;
- (UIScrollView *)pageForDisplayIdentifier:(id)arg1;
- (void)forceDismissAnimated:(BOOL)arg1;
- (void)sliderScroller:(id)scroller itemTapped:(unsigned)tapped;

- (void)showDetail:(UIViewController *)rootVC_arg;
        
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

@interface SBAppSliderWindowController : NSObject <UIGestureRecognizerDelegate> {
    
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
//长按0.8秒后触发事件
		longPressGR.minimumPressDuration = 0.8;
		[self.view addGestureRecognizer:longPressGR];
    
    
    
    
    parentView = [[UIView alloc] initWithFrame:CGRectMake(0, 350, 320, 200)];
    parentView.backgroundColor = [UIColor yellowColor];
    //parentView.tag = 1000;
    
    parentView.alpha = 0;
    [rootVC.view addSubview:parentView];
    [UIView animateWithDuration:0.28f animations:^{
        parentView.alpha = 1;
    }];
    
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(20, 20, 90, 35);
    
    [btn setTitle:@"ZoomIn" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(showDetail) forControlEvents:UIControlEventTouchUpInside];
    [parentView addSubview:btn];
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


-(void)sliderScroller:(id)scroller itemTapped:(unsigned)tapped {
    [UIView animateWithDuration:0.5f animations:^{
        parentView.alpha = 0;
    }];
    %orig;
}

-(void)forceDismissAnimated:(BOOL)animated {
    [UIView animateWithDuration:0.5f animations:^{
        parentView.alpha = 0;
    }];
    if (rootVC.popupViewController != nil) {
        [rootVC dismissPopupViewControllerAnimated:YES completion:^{}];
    }
    %orig;
}


- (void)switcherWillBeDismissed:(BOOL)switcher {       //妈蛋这是个标题党，实际效果是DidBeDissmiss
    [self.view removeGestureRecognizer:longPressGR];
    [parentView removeFromSuperview];
    
    [UIView animateWithDuration:0.5f animations:^{
        parentView.alpha = 0;
    }];
    if (rootVC.popupViewController != nil) {
        [rootVC dismissPopupViewControllerAnimated:YES completion:^{}];
    }
    %orig;
}

%new
- (void)showDetail{
    /* UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPopup)];
     tapRecognizer.numberOfTapsRequired = 1;
     tapRecognizer.delegate = self;
     [rootVC.view addGestureRecognizer:tapRecognizer];*/
    
    
    rootVC.useBlurForPopup = YES;
    
    UIViewController *samplePopupViewController = [[UIViewController alloc] init];
    /*UIToolbar *toolbarBackground = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 44, 200, 106)];
     [samplePopupViewController.view addSubview:toolbarBackground];
     [samplePopupViewController.view sendSubviewToBack:toolbarBackground];*/
    
    [rootVC presentPopupViewController:samplePopupViewController animated:YES completion:^(void) {
    }];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = CGRectMake(100, 400, 90, 35);
    
    [btn setTitle:@"ZoomOut" forState:UIControlStateNormal];
    [btn setTitle:@"ZoomOut" forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(dismissPopup) forControlEvents:UIControlEventTouchUpInside];
    [samplePopupViewController.view addSubview:btn];
    
}

%new
- (void)dismissPopup {
    if (rootVC.popupViewController != nil) {
        [rootVC dismissPopupViewControllerAnimated:YES completion:^{}];
    }
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

- (id)initWithRootViewController:(id)rootViewController {
    rootVC = (UIViewController *)rootViewController;
   
    
    %orig((id)rootVC);
    return %orig((id)rootVC);
}






/*%new
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return touch.view != rootVC.popupViewController.view;
}*/

%end





#line 1 "/Users/meilingrui/Desktop/Projects/Statia/Statia/Statia.xm"
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



#include <logos/logos.h>
#include <substrate.h>
@class SBAppSliderController; 
static void (*_logos_orig$_ungrouped$SBAppSliderController$switcherWasPresented$)(SBAppSliderController*, SEL, _Bool); static void _logos_method$_ungrouped$SBAppSliderController$switcherWasPresented$(SBAppSliderController*, SEL, _Bool); static BOOL (*_logos_orig$_ungrouped$SBAppSliderController$sliderScroller$isIndexRemovable$)(SBAppSliderController*, SEL, id, unsigned int); static BOOL _logos_method$_ungrouped$SBAppSliderController$sliderScroller$isIndexRemovable$(SBAppSliderController*, SEL, id, unsigned int); static void (*_logos_orig$_ungrouped$SBAppSliderController$_quitAppAtIndex$)(SBAppSliderController*, SEL, unsigned int); static void _logos_method$_ungrouped$SBAppSliderController$_quitAppAtIndex$(SBAppSliderController*, SEL, unsigned int); static void (*_logos_orig$_ungrouped$SBAppSliderController$switcherWillBeDismissed$)(SBAppSliderController*, SEL, BOOL); static void _logos_method$_ungrouped$SBAppSliderController$switcherWillBeDismissed$(SBAppSliderController*, SEL, BOOL); static void _logos_method$_ungrouped$SBAppSliderController$quitAll(SBAppSliderController*, SEL); 

#line 49 "/Users/meilingrui/Desktop/Projects/Statia/Statia/Statia.xm"



static void _logos_method$_ungrouped$SBAppSliderController$switcherWasPresented$(SBAppSliderController* self, SEL _cmd, _Bool arg1) {
		longPressGR = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(quitAll)];

		longPressGR.minimumPressDuration = 0.8;
		[self.view addGestureRecognizer:longPressGR];
    _logos_orig$_ungrouped$SBAppSliderController$switcherWasPresented$(self, _cmd, arg1);
}

static BOOL _logos_method$_ungrouped$SBAppSliderController$sliderScroller$isIndexRemovable$(SBAppSliderController* self, SEL _cmd, id arg1, unsigned int arg2) {
        return YES;
}

static void _logos_method$_ungrouped$SBAppSliderController$_quitAppAtIndex$(SBAppSliderController* self, SEL _cmd, unsigned int arg1) {
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
              _logos_orig$_ungrouped$SBAppSliderController$_quitAppAtIndex$(self, _cmd, arg1);
}
static void _logos_method$_ungrouped$SBAppSliderController$switcherWillBeDismissed$(SBAppSliderController* self, SEL _cmd, BOOL switcher) {
    [self.view removeGestureRecognizer:longPressGR];
    _logos_orig$_ungrouped$SBAppSliderController$switcherWillBeDismissed$(self, _cmd, switcher);
}





static void _logos_method$_ungrouped$SBAppSliderController$quitAll(SBAppSliderController* self, SEL _cmd){
        NSString *nowPlayingAppID = [[(SpringBoard *)[UIApplication sharedApplication] nowPlayingApp] bundleIdentifier];
		for (NSString *appID in [self applicationList]) {
        if (![appID isEqualToString:@"com.apple.springboard"]&&![appID isEqualToString:nowPlayingAppID])
        {
                UIScrollView *appPage = (UIScrollView *)[[self pageForDisplayIdentifier:appID] superview];
    
                
             
                [UIView animateWithDuration:0.4f animations:^{
                    appPage.alpha = 0;
                } completion:^(BOOL finished) {
                    [self _quitAppAtIndex:[[self applicationList] indexOfObject:appID]];
                }];
        }
		
    }
}







static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$SBAppSliderController = objc_getClass("SBAppSliderController"); MSHookMessageEx(_logos_class$_ungrouped$SBAppSliderController, @selector(switcherWasPresented:), (IMP)&_logos_method$_ungrouped$SBAppSliderController$switcherWasPresented$, (IMP*)&_logos_orig$_ungrouped$SBAppSliderController$switcherWasPresented$);MSHookMessageEx(_logos_class$_ungrouped$SBAppSliderController, @selector(sliderScroller:isIndexRemovable:), (IMP)&_logos_method$_ungrouped$SBAppSliderController$sliderScroller$isIndexRemovable$, (IMP*)&_logos_orig$_ungrouped$SBAppSliderController$sliderScroller$isIndexRemovable$);MSHookMessageEx(_logos_class$_ungrouped$SBAppSliderController, @selector(_quitAppAtIndex:), (IMP)&_logos_method$_ungrouped$SBAppSliderController$_quitAppAtIndex$, (IMP*)&_logos_orig$_ungrouped$SBAppSliderController$_quitAppAtIndex$);MSHookMessageEx(_logos_class$_ungrouped$SBAppSliderController, @selector(switcherWillBeDismissed:), (IMP)&_logos_method$_ungrouped$SBAppSliderController$switcherWillBeDismissed$, (IMP*)&_logos_orig$_ungrouped$SBAppSliderController$switcherWillBeDismissed$);{ char _typeEncoding[1024]; unsigned int i = 0; _typeEncoding[i] = 'v'; i += 1; _typeEncoding[i] = '@'; i += 1; _typeEncoding[i] = ':'; i += 1; _typeEncoding[i] = '\0'; class_addMethod(_logos_class$_ungrouped$SBAppSliderController, @selector(quitAll), (IMP)&_logos_method$_ungrouped$SBAppSliderController$quitAll, _typeEncoding); }} }
#line 149 "/Users/meilingrui/Desktop/Projects/Statia/Statia/Statia.xm"

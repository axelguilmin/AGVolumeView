//
//  AGVolumeView.h
//
//  Created by Axel Guilmin on 7/19/15.
//

#import <MediaPlayer/MediaPlayer.h>

/**
 Receive events captured by `AGVolumeView`
 */
@protocol AGVolumeViewDelegate <NSObject>
@optional
/// + physical button has been pressed
- (void)volumeUpPressed;
/// - physical button has been pressed
- (void)volumeDownPressed;
@end

/**
 A MPVolumeView that capture volume button pressed events.
 You can disable the event capturing with `ignore` and re-enable it with `capture`.
 Setting `hidden` to YES, `alpha` or `layer.opacity` to 0.0 will display the system popup when the sound
 */
@interface AGVolumeView : MPVolumeView
@property (nonatomic, assign) id<AGVolumeViewDelegate> delegate;
///
+ (instancetype)hiddenVolumeViewWithDelegate:(id<AGVolumeViewDelegate>)delegate;
/// Capture the touches on physical buttons
- (void)capture;
/// Behave like a standard MPVolumeView
- (void)ignore;
@end

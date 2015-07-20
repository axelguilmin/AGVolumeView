//
//  AGVolumeView.m
//
//  Created by Axel Guilmin on 7/19/15.
//

#import "AGVolumeView.h"

#import <AVFoundation/AVAudioSession.h>

@interface AGVolumeView()

@property(nonatomic, assign) float originalVolume;
@property(nonatomic, assign) BOOL capturing;
@property(nonatomic, assign) BOOL interrupted;

@end

@implementation AGVolumeView

#pragma mark - INIT

+ (instancetype)hiddenVolumeViewWithDelegate:(id<AGVolumeViewDelegate>)delegate {
	AGVolumeView *instance = [[AGVolumeView alloc] initWithFrame:CGRectMake(0, -200, 20, 20)];
	instance.showsRouteButton = NO;
	instance.userInteractionEnabled = NO;
	instance.delegate = delegate;
	return instance;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if(self) {
		_capturing = NO;
		_interrupted = NO;
		[self capture];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(audioSessionInterruptionNotification:)
													 name:AVAudioSessionInterruptionNotification
												   object:nil];
	}
	return self;
}

- (void)dealloc {
	[self ignore];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

#pragma mark - METHODS

- (void)capture {
	NSAssert([[NSThread currentThread] isMainThread], @"This must be called from the main thread");
	
	if(_capturing) return; else _capturing = YES;
	if(_interrupted) return;
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	
	NSError *error = nil;
	if (![audioSession setCategory:AVAudioSessionCategoryAmbient error:&error]) {
		NSLog(@"%@ Error setting category: %@", NSStringFromSelector(_cmd), [error localizedDescription]);
	}
	
	if (![audioSession setActive:YES error:&error]) {
		NSLog(@"%@", [error localizedDescription]);
	}
	
	float outputVolume = [audioSession outputVolume];
	// When the volume is 16/16 the '+' button event is not triggered
	// When the volume is 0/16 the '-' button event is not triggered
	_originalVolume = MAX(MIN(outputVolume, 15/16.f), 1/16.f);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		 [self setVolume:_originalVolume];
	});
	
	[audioSession addObserver:self
				   forKeyPath:@"outputVolume"
					  options:0
					  context:nil];
}

- (void)ignore {
	NSAssert([[NSThread currentThread] isMainThread], @"This must be called from the main thread");
	
	if(!_capturing) return; else _capturing = NO;
	if(_interrupted) return;
	
	AVAudioSession *audioSession = [AVAudioSession sharedInstance];
	
	NSError *error = nil;
	if (![audioSession setActive:NO error:&error]) {
		NSLog(@"%@", [error localizedDescription]);
	}
	
	[audioSession removeObserver:self forKeyPath:@"outputVolume"];
}

#pragma mark - PRIVATE

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	if ( ! [keyPath isEqual:@"outputVolume"])
		return;
	
	// Trigger delegate methods
	float volume = [[AVAudioSession sharedInstance] outputVolume];
	if(volume < _originalVolume) {
		[self volumeDown];
	}
	else if(volume > _originalVolume){
		[self volumeUp];
	}
	
	// Reset volume to original level
	[self setVolume:_originalVolume];
}

- (void)setVolume:(float)volume {
	for (UIView *view in [self subviews]){
		if ([view.class.description isEqualToString:@"MPVolumeSlider"]) {
			UISlider *volumeViewSlider = (UISlider*)view;
			[volumeViewSlider setValue:volume];
			return;
		}
	}
}

- (void)volumeUp {
	if (_delegate && [_delegate respondsToSelector:@selector(volumeUpPressed)]) {
		[_delegate volumeUpPressed];
	}
}

- (void)volumeDown {
	if (_delegate && [_delegate respondsToSelector:@selector(volumeDownPressed)]) {
		[_delegate volumeDownPressed];
	}
}

#pragma mark - NOTIFICATIONS

- (void)audioSessionInterruptionNotification:(NSNotification *)notification {
	NSDictionary *interuptionDict = notification.userInfo;
	NSInteger interuptionType = [[interuptionDict valueForKey:AVAudioSessionInterruptionTypeKey] integerValue];
	switch (interuptionType) {
		case AVAudioSessionInterruptionTypeBegan:
			[self ignore];
			_interrupted = YES;
			break;
			
		case AVAudioSessionInterruptionTypeEnded:
			_interrupted = NO;
			[self capture];
			break;
			
		default:
			NSLog(@"Audio Session Interruption Notification case default.");
			break;
	}
}

@end
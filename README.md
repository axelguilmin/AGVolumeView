# AGVolumeView

### Goal
This class allow to trigger another action than changing the volume when the user presses the physical button on the right of the iPhone/iPad.

### How to use it
##### Implement `AGVolumeViewDelegate`
    #import "AGVolumeView.h"
    @interface MyViewController () <AGVolumeViewDelegate>
    
    // ...
    
    - (void)volumeDownPressed {
        // Your action when the '-' is pressed
    }

    - (void)volumeUpPressed {
        // Your action when the '+' is pressed
    }
##### Add an AGVolumeView in your view hierarchy
    - (void)viewDidLoad {
        [super viewDidLoad];
        AGVolumeView *volumeView = [AGVolumeView hiddenVolumeViewWithDelegate:self];
        [self.view addSubview:volumeView];
        
        // ...
    }
By default, the view is moved outside of the screen so the user don't see it as its sole purpose is to catch the button events.
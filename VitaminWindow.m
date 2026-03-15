#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

//==============================================================================
// MARK: - Vitamin GUI Components (Pure Objective-C)
//==============================================================================

@interface VitaminWindow : UIWindow
@property (nonatomic, strong) UIButton *toggleButton;
@property (nonatomic, strong) UIView *mainPanel;
@property (nonatomic, assign) BOOL isVisible;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@end

@implementation VitaminWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert + 1;
        self.backgroundColor = [UIColor clearColor];
        self.rootViewController = [UIViewController new];
        self.rootViewController.view.backgroundColor = [UIColor clearColor];
        
        [self setupToggleButton];
        [self setupMainPanel];
        
        self.isVisible = NO;
        self.mainPanel.hidden = YES;
    }
    return self;
}

- (void)setupToggleButton {
    // Create the floating toggle button (Vitamin pill icon)
    self.toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.toggleButton.frame = CGRectMake(20, 100, 60, 60);
    
    // Create custom pill icon programmatically
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(60, 60), NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw pill shape
    CGContextSetFillColorWithColor(ctx, [UIColor systemGreenColor].CGColor);
    CGContextAddEllipseInRect(ctx, CGRectMake(10, 15, 40, 30));
    CGContextFillPath(ctx);
    
    // Draw "V" on the pill
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    UIFont *font = [UIFont boldSystemFontOfSize:24];
    NSDictionary *attributes = @{NSFontAttributeName: font, NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:@"V" attributes:attributes];
    [text drawAtPoint:CGPointMake(23, 18)];
    
    UIImage *pillImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.toggleButton setImage:pillImage forState:UIControlStateNormal];
    [self.toggleButton addTarget:self action:@selector(toggleButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    // Make it draggable
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self.toggleButton addGestureRecognizer:self.panGesture];
    
    [self addSubview:self.toggleButton];
}

- (void)setupMainPanel {
    // Main GUI panel that appears when toggled
    self.mainPanel = [[UIView alloc] initWithFrame:CGRectMake(100, 150, 250, 350)];
    self.mainPanel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.95];
    self.mainPanel.layer.cornerRadius = 20;
    self.mainPanel.layer.borderWidth = 2;
    self.mainPanel.layer.borderColor = [UIColor systemGreenColor].CGColor;
    self.mainPanel.clipsToBounds = YES;
    
    // Header with title and custom icon
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 250, 60)];
    header.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    
    // Vitamin icon in header
    UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 30, 30)];
    iconView.backgroundColor = [UIColor systemGreenColor];
    iconView.layer.cornerRadius = 15;
    
    // Draw "V" on icon
    UILabel *vLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 15, 20)];
    vLabel.text = @"V";
    vLabel.textColor = [UIColor whiteColor];
    vLabel.font = [UIFont boldSystemFontOfSize:18];
    [iconView addSubview:vLabel];
    
    [header addSubview:iconView];
    
    // Title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 15, 120, 30)];
    titleLabel.text = @"VITAMIN";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont boldSystemFontOfSize:22];
    [header addSubview:titleLabel];
    
    // Close button
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    closeButton.frame = CGRectMake(210, 15, 30, 30);
    [closeButton setTitle:@"✕" forState:UIControlStateNormal];
    [closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(hidePanel) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:closeButton];
    
    [self.mainPanel addSubview:header];
    
    // Content area
    UIView *content = [[UIView alloc] initWithFrame:CGRectMake(0, 60, 250, 240)];
    content.backgroundColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    
    // Feature buttons with custom icons
    NSArray *features = @[@"⚡ Turbo Mode", @"🛡️ Safe Mode", @"🎮 Game Boost", @"📊 Stats"];
    for (int i = 0; i < features.count; i++) {
        UIButton *featureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        featureButton.frame = CGRectMake(20, 20 + (i * 50), 210, 40);
        featureButton.backgroundColor = [UIColor colorWithWhite:0.25 alpha:1.0];
        featureButton.layer.cornerRadius = 10;
        featureButton.tag = i;
        
        [featureButton setTitle:features[i] forState:UIControlStateNormal];
        [featureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        featureButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        featureButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
        
        [featureButton addTarget:self action:@selector(featureTapped:) forControlEvents:UIControlEventTouchUpInside];
        [content addSubview:featureButton];
    }
    
    [self.mainPanel addSubview:content];
    
    // Footer
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 300, 250, 50)];
    footer.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    
    UILabel *versionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, 250, 20)];
    versionLabel.text = @"Version 1.0.0 • By Fren";
    versionLabel.textColor = [UIColor grayColor];
    versionLabel.font = [UIFont systemFontOfSize:12];
    versionLabel.textAlignment = NSTextAlignmentCenter;
    [footer addSubview:versionLabel];
    
    [self.mainPanel addSubview:footer];
    
    [self addSubview:self.mainPanel];
}

- (void)toggleButtonTapped {
    self.isVisible = !self.isVisible;
    self.mainPanel.hidden = !self.isVisible;
    
    // Animate
    [UIView animateWithDuration:0.3 animations:^{
        self.mainPanel.alpha = self.isVisible ? 1.0 : 0.0;
    }];
}

- (void)hidePanel {
    self.isVisible = NO;
    self.mainPanel.hidden = YES;
    self.mainPanel.alpha = 0.0;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self];
    gesture.view.center = CGPointMake(gesture.view.center.x + translation.x, 
                                       gesture.view.center.y + translation.y);
    [gesture setTranslation:CGPointZero inView:self];
}

- (void)featureTapped:(UIButton *)sender {
    NSString *message = [NSString stringWithFormat:@"%@ activated!", 
                         [sender titleForState:UIControlStateNormal]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Vitamin"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    
    // Find the topmost view controller to present the alert
    UIViewController *topVC = [self topMostController];
    [topVC presentViewController:alert animated:YES completion:nil];
}

- (UIViewController *)topMostController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    return topController;
}

@end

//==============================================================================
// MARK: - Constructor (Runs when dylib is loaded)
//==============================================================================

__attribute__((constructor))
static void vitaminInitializer() {
    NSLog(@"🔬 Vitamin dylib loaded successfully!");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        // Create and show the vitamin window
        CGRect screenBounds = [UIScreen mainScreen].bounds;
        VitaminWindow *vitaminWindow = [[VitaminWindow alloc] initWithFrame:screenBounds];
        vitaminWindow.hidden = NO;
        
        // Keep a reference so it doesn't get deallocated
        objc_setAssociatedObject([UIApplication sharedApplication], 
                                 @"kVitaminWindowKey", 
                                 vitaminWindow, 
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        NSLog(@"🍏 Vitamin GUI created and ready");
    });
}

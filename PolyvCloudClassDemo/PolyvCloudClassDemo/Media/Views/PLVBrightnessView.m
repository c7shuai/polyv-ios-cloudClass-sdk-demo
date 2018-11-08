//
//  PLVBrightnessView.m
//  PolyvCloudClassDemo
//
//  Created by zykhbl on 2018/8/14.
//  Copyright © 2018年 polyv. All rights reserved.
//

#import "PLVBrightnessView.h"
#import <Masonry/Masonry.h>

#define BrightnessViewWidth     155.0
#define BrightnessViewHeight    155.0

@interface PLVBrightnessView ()

@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UIImageView *backImgView;
@property (nonatomic, strong) UIView *brightnessLevelView;
@property (nonatomic, strong) NSMutableArray *tipArray;
@property (nonatomic, assign) BOOL addedInSubview;

@end

@implementation PLVBrightnessView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
}

+ (instancetype)sharedBrightnessView {
    static PLVBrightnessView *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PLVBrightnessView alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 10.0;
        self.alpha = 0.0;
        
        [self setupUI];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
        [[UIScreen mainScreen] addObserver:self forKeyPath:@"brightness" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)setupUI {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, BrightnessViewWidth, BrightnessViewHeight)];
    toolbar.backgroundColor = [UIColor colorWithRed:120.0 / 255.0 green:120.0 / 255.0 blue:120.0 / 255.0 alpha:1.0f];
    [self addSubview:toolbar];
    
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 5.0, BrightnessViewWidth, 30.0)];
    self.title.font  = [UIFont boldSystemFontOfSize:16.0];
    self.title.textColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.0f];
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.text = @"亮度";
    [self addSubview:self.title];
    
    self.backImgView = [[UIImageView alloc] initWithFrame:CGRectMake((BrightnessViewWidth - 79.0) * 0.5, self.title.frame.origin.y + self.title.frame.size.height + 5.0, 79.0, 76.0)];
    self.backImgView.image = [UIImage imageNamed:[@"PLVPlayerSkin.bundle" stringByAppendingPathComponent:@"skin_brightness"]];
    [self addSubview:self.backImgView];
    
    self.brightnessLevelView = [[UIView alloc] initWithFrame:CGRectMake(13.0, 132.0, BrightnessViewWidth - 26.0, 7.0)];
    self.brightnessLevelView.backgroundColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
    [self addSubview:self.brightnessLevelView];
    [self addSubview:self.brightnessLevelView];
    
    self.tipArray = [NSMutableArray arrayWithCapacity:16];
    CGFloat tipW = (self.brightnessLevelView.bounds.size.width - 17) / 16;
    CGFloat tipH = 5.0;
    CGFloat tipY = 1.0;
    for (int i = 0; i < 16; i++) {
        CGFloat tipX = i * (tipW + 1) + 1;
        UIImageView *imgView = [[UIImageView alloc] init];
        imgView.backgroundColor = [UIColor whiteColor];
        imgView.frame = CGRectMake(tipX, tipY, tipW, tipH);
        [self.brightnessLevelView addSubview:imgView];
        [self.tipArray addObject:imgView];
    }
    [self updateBrightnessLevel:[UIScreen mainScreen].brightness];
}

- (void)updateBrightnessLevel:(CGFloat)brightness {
    NSInteger level = brightness * 15.0;
    for (NSInteger i = 0; i < self.tipArray.count; i++) {
        UIImageView *imgView = self.tipArray[i];
        if (i <= level) {
            imgView.hidden = NO;
        } else {
            imgView.hidden = YES;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!self.addedInSubview) {
        self.addedInSubview = YES;
        UIWindow *window = [UIApplication sharedApplication].delegate.window;
        [window addSubview:self];
        __weak typeof(self) weakSelf = self;
        [self mas_remakeConstraints:^(MASConstraintMaker *make) {
            UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
            CGFloat x = 0.0;
            CGFloat y = 0.0;
            CGFloat angle = 0.0;
            if (UIDeviceOrientationIsLandscape(orientation)) {
                angle = (orientation == UIDeviceOrientationLandscapeRight ? -M_PI_2 : M_PI_2);
                x = 1.0;
                y = 1.0;
            } else {
                y = -5.0;
            }
            make.centerX.equalTo(window.mas_centerX).mas_offset(x);
            make.centerY.equalTo(window.mas_centerY).mas_offset(y);
            make.width.mas_equalTo(BrightnessViewWidth);
            make.height.mas_equalTo(BrightnessViewHeight);
            weakSelf.transform = CGAffineTransformMakeRotation(angle);
        }];
    }
    
    [self appearBrightnessView];
    [self updateBrightnessLevel:[change[@"new"] floatValue]];
}

- (void)appearBrightnessView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(disAppearBrightnessView) object:nil];
    
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.alpha = 1.0;
    } completion:^(BOOL finished) {
        [weakSelf performSelector:@selector(disAppearBrightnessView) withObject:nil afterDelay:2.0];
    }];
}

- (void)disAppearBrightnessView {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.5 animations:^{
        weakSelf.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.addedInSubview = NO;
        [self removeFromSuperview];
    }];
}

- (void)deviceOrientationDidChange {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    CGFloat angle = 0.0;
    if (UIDeviceOrientationIsLandscape(orientation)) {
        angle = (orientation == UIDeviceOrientationLandscapeRight ? -M_PI_2 : M_PI_2);
    }
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:[[UIApplication sharedApplication] statusBarOrientationAnimationDuration] delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.transform = CGAffineTransformMakeRotation(angle);
    } completion:nil];
}

@end

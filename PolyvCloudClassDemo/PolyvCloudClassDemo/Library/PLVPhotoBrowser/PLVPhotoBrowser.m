//
//  PLVPhotoBrowser.m
//  PolyvCloudClassDemo
//
//  Created by ftao on 2018/10/24.
//  Copyright © 2018 polyv. All rights reserved.
//

#import "PLVPhotoBrowser.h"
#import "PLVAuthorizationManager.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <Masonry/Masonry.h>

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface PLVPhotoBrowser ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, assign) CGRect originFrame;

@end

@implementation PLVPhotoBrowser

- (void)scaleImageViewToFullScreen:(UIImageView *)imageView {
    self.image = imageView.image;
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    self.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.backgroundView setBackgroundColor:[UIColor blackColor]];
    [self.backgroundView setAlpha:0];
    [window addSubview:self.backgroundView];
    
    self.originFrame = [imageView convertRect:imageView.bounds toView:window];
    UIImageView *largeImageView = [[UIImageView alloc] initWithFrame:self.originFrame];
    [largeImageView setImage:imageView.image];
    [largeImageView setTag:10];
    [self.backgroundView addSubview:largeImageView];
    
    UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [downloadBtn setImage:[UIImage imageNamed:@"plv_btn_download"] forState:UIControlStateNormal];
    [downloadBtn addTarget:self action:@selector(downloadButtonBeClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundView addSubview:downloadBtn];
    [downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
        make.right.equalTo(self.backgroundView.mas_right).offset(-15.0);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.backgroundView.mas_safeAreaLayoutGuideBottom).offset(-15.0);
        } else {
            make.bottom.equalTo(self.backgroundView.mas_bottom).offset(-15.0);
        }
    }];
    
    CGFloat newHeight = SCREEN_WIDTH * imageView.image.size.height / imageView.image.size.width;
    [UIView animateWithDuration:0.3 animations:^{
        [largeImageView setFrame:CGRectMake(0, 0, SCREEN_WIDTH, newHeight)];
        [largeImageView setCenter:self.backgroundView.center];
        [self.backgroundView setAlpha:1];
    } completion:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self.backgroundView addGestureRecognizer:tapGesture];
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGesture:)];
    [self.backgroundView addGestureRecognizer:pinchGesture];
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGseture:)];
    [self.backgroundView addGestureRecognizer:panGesture];
}

#pragma mark - Privates

- (void)tapGesture:(UIGestureRecognizer *)recognizer {
    UIImageView *imageView = [self.backgroundView viewWithTag:10];
    [UIView animateWithDuration:0.3 animations:^{
        [imageView setFrame:self.originFrame];
        [self.backgroundView setAlpha:0];
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
    }];
}

- (void)pinchGesture:(UIPinchGestureRecognizer *)recognizer {
    UIImageView *imageView = [self.backgroundView viewWithTag:10];
    if (recognizer.state==UIGestureRecognizerStateBegan
        || recognizer.state==UIGestureRecognizerStateChanged) {
        imageView.transform = CGAffineTransformScale(imageView.transform, recognizer.scale, recognizer.scale);
        recognizer.scale = 1.0;
    }
}

- (void)panGseture:(UIPanGestureRecognizer *)recognizer {
    UIImageView *imageView = [self.backgroundView viewWithTag:10];
    if (recognizer.state==UIGestureRecognizerStateBegan
        || recognizer.state==UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self.backgroundView];
        [imageView setCenter:CGPointMake(imageView.center.x + translation.x, imageView.center.y + translation.y)];
        [recognizer setTranslation:CGPointZero inView:self.backgroundView];
    }
}

- (void)downloadButtonBeClicked {
    PLVAuthorizationStatus status = [PLVAuthorizationManager authorizationStatusWithType:PLVAuthorizationTypePhotoLibrary];
    switch (status) {
        case PLVAuthorizationStatusAuthorized: {
            UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        } break;
        case PLVAuthorizationStatusDenied: {
            [self showHUDWithTitle:@"您无权访问相册，请授权后重新保存" detail:nil];
        } break;
        case PLVAuthorizationStatusNotDetermined: {
            [PLVAuthorizationManager requestAuthorizationWithType:PLVAuthorizationTypePhotoLibrary completion:^(BOOL granted) {
                if (granted) {
                    UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                }else {
                    [self showHUDWithTitle:@"授权失败，无法保存至您的相册" detail:nil];
                }
            }];
        } break;
        default:
            break;
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if (error) {
        [self showHUDWithTitle:@"图片保存至相册失败" detail:error.localizedDescription];
    }else {
        [self showHUDWithTitle:@"图片已保存到系统相册" detail:nil];
    }
}

- (void)showHUDWithTitle:(NSString *)title detail:(NSString *)detail {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.backgroundView animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = title;
    hud.detailsLabel.text = detail;
    [hud hideAnimated:YES afterDelay:3.0];
}

@end

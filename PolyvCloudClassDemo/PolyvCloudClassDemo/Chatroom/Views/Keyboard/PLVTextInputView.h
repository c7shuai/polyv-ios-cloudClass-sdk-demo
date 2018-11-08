//
//  PLVTextInputView.h
//  PolyvCloudClassDemo
//
//  Created by zykhbl on 2018/9/7.
//  Copyright © 2018年 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PLVTextInputViewType) {
    PLVTextInputViewTypePublic      = 1,//公聊
    PLVTextInputViewTypePrivate     = 2 //私聊
};

@protocol PLVTextInputViewDelegate;

@interface PLVTextInputView : UIView

@property (nonatomic, weak) id<PLVTextInputViewDelegate> delegate;

- (void)loadViews:(PLVTextInputViewType)type;
- (void)nickNameSetted:(BOOL)setted;

//横屏时调用，隐藏键盘
- (void)tapAction;

@end

@protocol PLVTextInputViewDelegate <NSObject>

- (void)textInputView:(PLVTextInputView *)inputView followKeyboardAnimation:(BOOL)flag;
- (void)textInputView:(PLVTextInputView *)inputView didSendText:(NSString *)text;
- (void)sendFlower:(PLVTextInputView *)inputView;
- (void)textInputView:(PLVTextInputView *)inputView onlyTeacher:(BOOL)on;
- (void)textInputView:(PLVTextInputView *)inputView nickNameSetted:(BOOL)nickNameSetted;

@end

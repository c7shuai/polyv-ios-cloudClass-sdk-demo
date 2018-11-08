//
//  PLVChatroomController.h
//  PolyvCloudClassDemo
//
//  Created by ftao on 23/08/2018.
//  Copyright © 2018 polyv. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <PolyvCloudClassSDK/PLVLiveAPI.h>
#import <PolyvBusinessSDK/PLVSocketObject.h>
#import "PLVTextInputView.h"

/// 聊天室类型
typedef NS_ENUM(NSInteger, PLVChatroomType) {
    PLVChatroomTypePublic   = 1,  // 公共聊天
    PLVChatroomTypePrivate  = 2,  // 私有聊天(咨询提问)
};

/// 聊天室错误码
typedef NS_ENUM(NSInteger, PLVChatroomErrorCode) {
    PLVChatroomErrorCodeBeKicked    = -100,   // 无访问权限
    PLVChatroomErrorCodeRoomClose   = -111,   // 房间关闭
    PLVChatroomErrorCodeBanned      = -122,   // 被禁言
};

@class PLVChatroomController;

@protocol PLVChatroomDelegate <NSObject>
@required
- (void)chatroom:(PLVChatroomController *)chatroom didOpenError:(PLVChatroomErrorCode)code;
- (void)chatroom:(PLVChatroomController *)chatroom emitSocketObject:(PLVSocketChatRoomObject *)object;
- (void)chatroom:(PLVChatroomController *)chatroom nickNameRenamed:(NSString *)newName success:(BOOL)success message:(NSString *)message;
- (void)chatroom:(PLVChatroomController *)chatroom followKeyboardAnimation:(BOOL)flag;

@optional
- (void)chatroom:(PLVChatroomController *)chatroom didSendSpeakContent:(NSString *)content;

@end

@interface PLVChatroomController : UIViewController

@property (nonatomic, readonly) NSUInteger roomId;

@property (nonatomic, readonly) PLVChatroomType type;

/// 聊天室在线人数（实时）
@property (nonatomic, readonly) NSUInteger onlineCount;

@property (nonatomic, strong, readonly) PLVTextInputView *inputView;

@property (nonatomic, weak) id<PLVChatroomDelegate> delegate;

/// 登录 socket 的用户对象（必传，否则无法提交聊天室相关消息）
/// 该属性逐渐废弃，使用 PLVChatroomManager 中的 socketUser 值
@property (nonatomic, strong) PLVSocketObject *socketUser;

@property (nonatomic, getter=isClosed) BOOL close;

/// 是否有观看直播权限
+ (BOOL)havePermissionToWatchLive:(NSUInteger)roomId;

/// 便利初始化
+ (instancetype)chatroomWithType:(PLVChatroomType)type roomId:(NSUInteger)roomId frame:(CGRect)frame;
- (instancetype)initChatroomWithType:(PLVChatroomType)type roomId:(NSUInteger)roomId frame:(CGRect)frame;

/// 加载子视图
- (void)loadSubViews;

/// 添加新事件
- (void)addNewChatroomObject:(PLVSocketChatRoomObject *)object;

@end

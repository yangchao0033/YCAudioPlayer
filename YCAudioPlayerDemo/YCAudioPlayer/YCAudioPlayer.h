//
//  YCAudioPlayer.h
//  TestAVAudioPlyer
//
//  Created by 超杨 on 15/11/9.
//  Copyright © 2015年 超杨. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YCAudioPlayer : UIView
/*!
 *  @author 杨超, 15-11-10 12:11:12
 *
 *  @brief  工厂方法
 *
 *  @param url 本地视频播放url
 *
 *  @return 返回本类实例
 *
 *  @since <#version number#>
 */
+ (instancetype)audioPlayerWithUrl:(NSURL *)url;
/*!
 *  @author 杨超, 15-11-10 12:11:40
 *
 *  @brief  展示播放器页面
 *
 *  @param frame 播放器相对于window的frame
 *
 *  @since <#version number#>
 */
- (void)showPlayerWithPlayerFrameOnWindow:(CGRect)frame;
@end

//
//  YCAudioPlayer.m
//  TestAVAudioPlyer
//
//  Created by 超杨 on 15/11/9.
//  Copyright © 2015年 超杨. All rights reserved.
//

#import "YCAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
/** 为了让停止按钮的热区响应范围更大，如果有切图的可以直接设置item的image，不必导入此类 */
static BOOL knowHowToPlay = NO;
static const NSTimeInterval kBeginTransitionDuration = 1.0f;
static const NSTimeInterval kEndTransitionDuration = 0.6f;
static NSTimeInterval kTitleDisplayDutation = 10;
@interface YCAudioPlayer ()<AVAudioPlayerDelegate>
/** 主window */
@property (nonatomic, strong) UIWindow *keyWindow;
/** 起始时间 */
@property (weak, nonatomic) IBOutlet UILabel *benginTimeLbl;
@property (nonatomic, copy) NSString *beginTime;
/** 截止时间 */
@property (weak, nonatomic) IBOutlet UILabel *endTimeLbl;
@property (nonatomic, copy) NSString *endTime;
/** 进度条 */
@property (weak, nonatomic) IBOutlet UIProgressView *showPrograss;
/** 进度控制 */
@property (weak, nonatomic) IBOutlet UISlider *playControlPrograss;
/** 记录进度条是否被点击 */
@property (nonatomic, assign) BOOL prograssTapped;
/** 背景按钮 */
@property (nonatomic, strong) UIButton *bgView;
/** 播放器 */
@property (nonatomic, strong) AVAudioPlayer *avAudioPlayer;
/** 刷新进度条使用 */
@property (nonatomic, strong) NSTimer *timer;
/** 播放路径 */
@property (nonatomic, strong) NSURL *url;
/** 控制面板 */
@property (weak, nonatomic) IBOutlet UIButton *tapControlBtn;
/** 引导文字 */
@property (nonatomic, strong) IBOutlet UILabel *tipsLbl;
/** 工具条 */
@property (weak, nonatomic) IBOutlet UIToolbar *toolsBar;
/** 双击手势 */
@property (nonatomic, strong) UITapGestureRecognizer *tapGes;
/** 音乐标题 */
@property (weak, nonatomic) IBOutlet UILabel *musicTitle;
/** titleLeading约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *musicTitleLeading;

@end

@implementation YCAudioPlayer

+ (instancetype)audioPlayerWithUrl:(NSURL *)url{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil];
    NSArray *arr = [nib instantiateWithOwner:nil options:nil];
    YCAudioPlayer *player = [arr firstObject];
    player.url = url;
    player.musicTitle.text = url.lastPathComponent;
//    player.musicTitle.text = @"daskjndsalnfjksdfnkasdbhjsabdgasjkdjnsahbdjasfn";
//    kTitleDisplayDutation = 1.2 * player.musicTitle.text.length;
    player.playControlPrograss.hidden = !player.prograssTapped;
    player.layer.cornerRadius = 5;
    player.layer.masksToBounds = YES;
    UITapGestureRecognizer *doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:player action:@selector(prograssTap:)];
    player.tapGes = doubleTapGestureRecognizer;
    [doubleTapGestureRecognizer setNumberOfTapsRequired:2];
    [player.tapControlBtn addGestureRecognizer:doubleTapGestureRecognizer];
    player.endTimeLbl.text = player.endTime;
    return player;
}

#pragma mark 事件
- (IBAction)stopMusic:(UIButton *)sender {
//    NSLog(@"%s", __func__);
    [self.avAudioPlayer stop];
    [self.timer setFireDate:[NSDate distantFuture]];
    self.avAudioPlayer.currentTime = 0;
    self.showPrograss.progress = self.playControlPrograss.value = 0;
    self.benginTimeLbl.text = @"00:00";
}

- (IBAction)playMusic:(UIBarButtonItem *)sender {
//    NSLog(@"%s", __func__);
    /** 打开定时器 */
    [self.timer setFireDate:[NSDate date]];
    if (self.showPrograss.progress == 1) {
        self.showPrograss.progress = self.playControlPrograss.value = 0;
    }
    [self.avAudioPlayer play];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.timer setFireDate:[NSDate date]];
//    });
}

- (IBAction)pauseMusic:(UIBarButtonItem *)sender {
//    NSLog(@"%s", __func__);
    [self.timer setFireDate:[NSDate distantFuture]];
    [self.avAudioPlayer pause];
}

- (IBAction)prograssTap:(UITapGestureRecognizer *)ges {
    knowHowToPlay = YES;
    self.prograssTapped = !self.prograssTapped;
    self.playControlPrograss.hidden = !self.prograssTapped;
    self.tipsLbl.text = @"长按滑动滑钮 双击隐藏滑钮";
    [self insertSubview:self.playControlPrograss aboveSubview:self.tipsLbl];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:1.0 animations:^{
            self.tipsLbl.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.tipsLbl.hidden = YES;
            [self.tipsLbl removeFromSuperview];
        }];
    });
}

- (IBAction)playPrograssControl:(UISlider *)sender {
    if (knowHowToPlay && !self.tipsLbl.hidden) {
        self.tipsLbl.hidden = YES;
    }
    self.showPrograss.progress = sender.value;
    self.avAudioPlayer.currentTime = sender.value * self.avAudioPlayer.duration;
    self.benginTimeLbl.text = self.beginTime;
//    self.endTimeLbl.text = [NSString stringWithFormat:@"%.2d:%.2d", (int)self.avAudioPlayer.duration/60, (int)self.avAudioPlayer.duration % 60];
}


#pragma mark 公开方法
- (void)showPlayerWithPlayerFrameOnWindow:(CGRect)frame{
    [self transitionWithType:@"rippleEffect" WithSubtype:kCATransitionFromBottom ForView:self.keyWindow duration:kBeginTransitionDuration];
    [self animateTitle];
    self.frame = frame;
    [self.keyWindow addSubview:self.bgView];
    [self.bgView addSubview:self];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self
                                            selector:@selector(playProgress)
                                            userInfo:nil repeats:YES];;
    [self.timer setFireDate:[NSDate distantFuture]];
    [UIView animateWithDuration:0.2f animations:^{
        self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6f];
    } completion:nil];
    
    
    if (!knowHowToPlay) {
        /** 添加提示框 */
        self.tipsLbl.frame = _tipsLbl.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - self.toolsBar.frame.size.height);
        [UIView animateWithDuration:1.0 delay:2.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.tipsLbl.hidden = NO;
            self.tipsLbl.alpha = 0.6f;
            
        } completion:^(BOOL finished) {
            if (finished) {

            }
//
        }];
    }

}

#pragma 私有方法
- (void)hidePlayer {
    [self transitionWithType:@"suckEffect" WithSubtype:kCATransitionFromBottom ForView:self.keyWindow duration:kEndTransitionDuration];
    [UIView animateWithDuration:0.2f animations:^{
        self.bgView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self.avAudioPlayer stop];
        [self.timer invalidate];
        [self.bgView removeFromSuperview];
    }];
}


//播放进度条刷新
- (void)playProgress
{
    //通过音频播放时长的百分比,给progressview进行赋值;
    if (self.avAudioPlayer.currentTime < self.avAudioPlayer.duration) {
        self.showPrograss.progress = self.playControlPrograss.value = self.avAudioPlayer.currentTime/self.avAudioPlayer.duration;
        self.benginTimeLbl.text = self.beginTime;
    }
//    else {
//        self.benginTimeLbl.text = @"00:00";
//        self.showPrograss.progress = self.playControlPrograss.value = 0;
//    }
}


#pragma CATransition动画
- (void) transitionWithType:(NSString *) type WithSubtype:(NSString *) subtype ForView:(UIView *)view duration:(CFTimeInterval)duration
{
    //创建CATransition对象
    CATransition *animation = [CATransition animation];
    //设置运动时间
    animation.duration = duration;
    //设置运动type
    animation.type = type;
    if (subtype != nil) {
        //设置子类
        animation.subtype = subtype;
    }
    //设置运动速度
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
    [view.layer addAnimation:animation forKey:@"animation"];
}

/** 标题可动 */
- (void)animateTitle {
    [self.musicTitle sizeToFit];
    /** 动画偏移量 */
    CGFloat OffsetX = 0.0f;
    CGFloat beginX = 0.0f;
    CGSize sizeName = [self.musicTitle.text sizeWithFont:self.musicTitle.font
                          constrainedToSize:CGSizeMake(MAXFLOAT, 0.0)
                              lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat distance = fabs(sizeName.width - self.frame.size.width);
    CGFloat titleLeftInset = 5;
    if (self.frame.size.width > sizeName.width) {
        beginX = 0.0f + titleLeftInset;
        OffsetX = distance - titleLeftInset;
    } else {
        beginX = -distance - titleLeftInset;
        OffsetX = 0.0f + titleLeftInset;
    }
    
    self.musicTitleLeading.constant = beginX;
    [self.musicTitle layoutIfNeeded];
//    kTitleDisplayDutation = 1.2 * OffsetX;
    [UIView animateWithDuration:kTitleDisplayDutation delay:1 options:(UIViewAnimationOptionRepeat|UIViewAnimationOptionCurveLinear|UIViewAnimationOptionAutoreverse) animations:^{
        self.musicTitleLeading.constant = OffsetX;
        [self.musicTitle layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}


#pragma mark 播放音频
//播放完成时调用的方法  (代理里的方法),需要设置代理才可以调用
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
//    [self.timer invalidate]; //NSTimer暂停   invalidate  使...无效;
    [self.timer setFireDate:[NSDate distantFuture]];
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer*)player error:(NSError *)error{
    //解码错误执行的动作
}
- (void)audioPlayerBeginInteruption:(AVAudioPlayer*)player{
    //处理中断的代码
}
- (void)audioPlayerEndInteruption:(AVAudioPlayer*)player{
    //处理中断结束的代码
}
#pragma mark setter & getter
- (UIButton *)bgView
{
    if (_bgView == nil) {
        
        _bgView = [[UIButton alloc] init];
        _bgView.frame = self.keyWindow.bounds;
        _bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0f];
        [_bgView addTarget:self action:@selector(hidePlayer) forControlEvents:(UIControlEventTouchUpInside)];
        
    }
    return _bgView;
}
- (UIWindow *)keyWindow
{
    if (_keyWindow == nil) {
        _keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    return _keyWindow;
}

- (AVAudioPlayer *)avAudioPlayer
{
    if (_avAudioPlayer == nil) {
        _avAudioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
        //设置代理
        _avAudioPlayer.delegate = self;
        //设置初始音量大小
         _avAudioPlayer.volume = 1.0;
        //设置音乐播放次数  -1为一直循环
        _avAudioPlayer.numberOfLoops = 0;
        //预播放
        [_avAudioPlayer prepareToPlay];
    }
    return _avAudioPlayer;
}

- (UILabel *)tipsLbl
{
    if (_tipsLbl == nil) {
        _tipsLbl = [[UILabel alloc] init];
        _tipsLbl.layer.cornerRadius = 5;
        _tipsLbl.layer.masksToBounds = YES;
        _tipsLbl.layer.borderWidth = 1.0;
        _tipsLbl.layer.borderColor = [UIColor whiteColor].CGColor;
        _tipsLbl.backgroundColor = [UIColor blackColor];
        _tipsLbl.textColor = [UIColor whiteColor];
        _tipsLbl.textAlignment = NSTextAlignmentCenter;
        _tipsLbl.alpha = 0.0;
        _tipsLbl.hidden = YES;
        _tipsLbl.text = @"双击这里显示调整进度条";
//        [_tipsLbl addGestureRecognizer:self.tapGes];
        [self addSubview:_tipsLbl];
    }
    return _tipsLbl;
}
- (NSString *)beginTime
{
    return [NSString stringWithFormat:@"%.2d:%.2d", (int)self.avAudioPlayer.currentTime / 60 , (int)self.avAudioPlayer.currentTime % 60];
}

- (NSString *)endTime {
    return [NSString stringWithFormat:@"%.2d:%.2d", (int)self.avAudioPlayer.duration/60, (int)self.avAudioPlayer.duration % 60];
}
@end

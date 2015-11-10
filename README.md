# YCAudioPlayer
快速集成一款简易的音乐播放器

## 用法
1. 将YCAudioPlayer文件夹拖入项目中
2. 使用工厂方法快速创建
```objc
    // 从budle路径下读取音频文件　　Katy Perry - Roar 这个文件名是你的歌曲名字,mp3是你的音频格式
    NSString *string = [[NSBundle mainBundle] pathForResource:@"Katy Perry - Roar" ofType:@"mp3"];
    // 把音频文件地址转换成url格式
    NSURL *url = [NSURL fileURLWithPath:string];
    YCAudioPlayer *player = [YCAudioPlayer audioPlayerWithUrl:url];
    CGRect frame = CGRectMake(5, [UIScreen mainScreen].bounds.size.height / 2 , [UIScreen mainScreen].bounds.size.width - 10, 180);
    // 设置控件在屏幕上的显示位置
    [player showPlayerWithPlayerFrameOnWindow:frame];
```

## 支持功能：
1. 控件基于系统自带AVAudioPlayer框架，所有音频源支持类型与其一致
2. 拥有音频播放、暂停、停止、进度显示、进度控制（双击歌曲名区域调出和召回进度控制条）
3. 支持长短歌曲名展示
4. 支持控件显示和隐藏的转场动画
5. 实时显示歌曲播放时间与总时间

## 效果展示
***
![效果展示](https://github.com/yangchao0033/YCAudioPlayer/blob/master/gif%E9%85%8D%E5%9B%BE.gif)


更多功能敬请期待。。。


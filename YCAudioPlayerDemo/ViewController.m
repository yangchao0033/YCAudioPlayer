//
//  ViewController.m
//  YCAudioPlayerDemo
//
//  Created by 超杨 on 15/11/10.
//  Copyright © 2015年 杨超. All rights reserved.
//

#import "ViewController.h"
#import "YCAudioPlayer.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"%s", __func__);
    //从budle路径下读取音频文件　　轻音乐 - 萨克斯回家 这个文件名是你的歌曲名字,mp3是你的音频格式
    NSString *string = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"];
    //把音频文件转换成url格式
    NSURL *url = [NSURL fileURLWithPath:string];
    YCAudioPlayer *player = [YCAudioPlayer audioPlayerWithUrl:url];
    CGRect frame = CGRectMake(5, [UIScreen mainScreen].bounds.size.height / 2 , [UIScreen mainScreen].bounds.size.width - 10, 180);
    [player showPlayerWithPlayerFrameOnWindow:frame];
}
@end

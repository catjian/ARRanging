//
//  RootViewController.m
//  ARRanging
//
//  Created by zhang_jian on 2018/3/21.
//  Copyright © 2018年 zhangjian. All rights reserved.
//

#import "RootViewController.h"
#import "ARRulerViewController.h"
//#import "ViewController.h"

#define mm_Widht  (736.f/140.f)

@interface RootViewController () <UIScrollViewDelegate>

@end

@implementation RootViewController
{
    UIScrollView *m_RulerView;
    NSInteger m_NumberValue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    m_NumberValue = 0;
    m_RulerView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
    CGAffineTransform transform =CGAffineTransformMakeRotation(M_PI_2);
    [m_RulerView setTransform:transform];
    [m_RulerView setDelegate:self];
    [self.view addSubview:m_RulerView];
    [m_RulerView setFrame:self.view.bounds];
    [m_RulerView setBackgroundColor:[UIColor yellowColor]];
    [m_RulerView setShowsHorizontalScrollIndicator:NO];
    [m_RulerView setShowsVerticalScrollIndicator:NO];
    [m_RulerView setContentSize:CGSizeMake(self.view.frame.size.height*3, 0)];
    [self addNumberValueAndLineToViewFromX:0];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, self.view.frame.size.height-40, 200, 40)];
    CGPoint centerBtn = button.center;
    centerBtn.x = self.view.center.x;
    [button setCenter:centerBtn];
    [button setTitle:@"使用AR尺子" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(pushToARRulerViewController) forControlEvents:UIControlEventTouchUpInside];
}

- (void)addNumberValueAndLineToViewFromX:(CGFloat)beginX
{
    CGFloat i = beginX;
    do
    {
        if (i >= beginX) {
            CGFloat offset_widht = 1;
            CGFloat offset_Height = 10;
            if (m_NumberValue%5 == 0)
            {
                offset_widht = 1;
                offset_Height = 20;
            }
            if (m_NumberValue%10 == 0)
            {
                offset_widht = 2;
                offset_Height = 30;
                UILabel *labT = [[UILabel alloc] initWithFrame:CGRectMake(beginX-mm_Widht*10/2, 40, mm_Widht*10, 20)];
                [labT setText:[@(m_NumberValue/10) stringValue]];
                [labT setTextAlignment:NSTextAlignmentCenter];
                [m_RulerView addSubview:labT];
                
                UILabel *labB = [[UILabel alloc] initWithFrame:CGRectMake(beginX-mm_Widht*10/2, self.view.frame.size.width-40-20, mm_Widht*10, 20)];
                [labB setText:[@(m_NumberValue/10) stringValue]];
                [labB setTextAlignment:NSTextAlignmentCenter];
                CGAffineTransform transform =CGAffineTransformMakeRotation(M_PI);
                [labB setTransform:transform];
                [m_RulerView addSubview:labB];
            }
            UIView *lineT = [[UIView alloc] initWithFrame:CGRectMake(beginX-(offset_widht==2?1:0), 0, offset_widht, offset_Height)];
            [lineT setBackgroundColor:[UIColor blackColor]];
            [m_RulerView addSubview:lineT];
            UIView *lineB = [[UIView alloc] initWithFrame:CGRectMake(beginX-(offset_widht==2?1:0), self.view.frame.size.width-offset_Height, offset_widht, offset_Height)];
            [lineB setBackgroundColor:[UIColor blackColor]];
            [m_RulerView addSubview:lineB];
            beginX += mm_Widht;
            m_NumberValue++;
        }
        i++;
    }
    while (i <= m_RulerView.contentSize.width);
}

- (void)removeNumberValueAndLineToViewFromX:(CGFloat)beginX
{
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > scrollView.contentSize.width-self.view.frame.size.height*2)
    {
        [m_RulerView setContentSize:CGSizeMake(scrollView.contentSize.width+self.view.frame.size.height, 0)];
        [self addNumberValueAndLineToViewFromX:scrollView.contentSize.width-self.view.frame.size.height];
    }
    else
    {
        //        [self removeNumberValueAndLineToViewFromX:scrollView.contentSize.width];
        //        [m_RulerView setContentSize:CGSizeMake(scrollView.contentSize.width-self.view.frame.size.height, 0)];
    }
}

- (void)pushToARRulerViewController
{
    if (![ARConfiguration isSupported])
    {
        UIAlertController *alertCon = [UIAlertController alertControllerWithTitle:@"提示" message:@"设备不支持AR" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [alertCon dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertCon addAction:cancelAction];
        [self presentViewController:alertCon animated:YES completion:nil];
        return;
    }
        ARRulerViewController *arVC = [[ARRulerViewController alloc] init];
        [self presentViewController:arVC animated:YES completion:nil];
    
//    ViewController *arVC = [[ViewController alloc] init];
//    [self presentViewController:arVC animated:YES completion:nil];
}

@end

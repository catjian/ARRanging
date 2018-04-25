//
//  ViewController.m
//  ARRanging
//
//  Created by zhang_jian on 2018/3/21.
//  Copyright © 2018年 zhangjian. All rights reserved.
//

#import "ARRulerViewController.h"
#import "LineController.h"
#import "PlaneNode.h"

@interface ARRulerViewController () <ARSCNViewDelegate, ARSessionDelegate>

@property (nonatomic, strong) ARSCNView *sceneView;

@end

    
@implementation ARRulerViewController
{
    SCNNode *m_FocusNode;
    UILabel *m_SpaceLab;
    SCNVector3 m_VectorZero;
    SCNVector3 m_VectorStart;
    SCNVector3 m_VectorEnd;
    LineController *m_lineCon;
    BOOL m_isMeasuring;
    NSMutableDictionary<NSUUID *, PlaneNode *> *m_planeArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    m_planeArr = [NSMutableDictionary dictionary];
    m_isMeasuring = NO;
    self.sceneView = [[ARSCNView alloc] initWithFrame:self.view.frame];
    self.sceneView.delegate = self;
    [self.sceneView setShowsStatistics:NO];//是否显示fps 或 timing等信息
    [self.sceneView setDebugOptions:ARSCNDebugOptionShowFeaturePoints]; //显示平面检测到的特征点（feature points）
    [self.sceneView setAutoenablesDefaultLighting:YES];
    [self.view addSubview:self.sceneView];
    
    SCNScene *scene = [[SCNScene alloc] init]; //创建场景
    SCNMaterial *material = [SCNMaterial material]; // material 渲染器
    material.diffuse.contents = [UIColor redColor];
    SCNCone *coneNode = [SCNCone coneWithTopRadius:.005 bottomRadius:.001 height:0.02];//创建一个椎体
    coneNode.materials = @[material];
    m_FocusNode = [SCNNode nodeWithGeometry:coneNode];//创建节点
    m_FocusNode.position = SCNVector3Make(0, 0.01, -0.5);
    [scene.rootNode addChildNode:m_FocusNode];
    
    self.sceneView.scene = scene;
    
    m_SpaceLab = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 30)];
    [m_SpaceLab setBackgroundColor:[UIColor lightGrayColor]];
    [m_SpaceLab setTextColor:[UIColor whiteColor]];
    [m_SpaceLab setTextAlignment:NSTextAlignmentCenter];
    [m_SpaceLab setText:@"初始化中"];
    [self.view addSubview:m_SpaceLab];
    
    UIImageView *crossMark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"crossMark"]];
    [crossMark setFrame:CGRectMake(0,0, 20, 20)];
    [crossMark setCenter:self.view.center];
    [self.view addSubview:crossMark];
    
    UIButton *addAnchor = [UIButton buttonWithType:UIButtonTypeCustom];
    [addAnchor setFrame:CGRectMake(100, self.view.frame.size.height-200, 100, 50)];
    CGPoint centerPoint = addAnchor.center;
    centerPoint.x = self.view.frame.size.width/2;
    [addAnchor setCenter:centerPoint];
    [addAnchor setTitle:@"添加锚点" forState:UIControlStateNormal];
    [addAnchor setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [addAnchor setTag:1001];
    [self.view addSubview:addAnchor];
    [addAnchor addTarget:self action:@selector(addAnchorButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cleanBtn setFrame:addAnchor.frame];
    centerPoint = addAnchor.center;
    centerPoint.y += 60;
    [cleanBtn setCenter:centerPoint];
    [cleanBtn setTitle:@"clean All" forState:UIControlStateNormal];
    [cleanBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [cleanBtn setTag:1002];
    [self.view addSubview:cleanBtn];
    [cleanBtn addTarget:self action:@selector(addAnchorButtonEvent:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    ARWorldTrackingConfiguration *confige = [ARWorldTrackingConfiguration new];
    // 明确表示需要追踪水平面。设置后 scene 被检测到时就会调用 ARSCNViewDelegate 方法
    [confige setPlaneDetection:ARPlaneDetectionHorizontal | ARPlaneDetectionVertical];
    [self.sceneView.session runWithConfiguration:confige];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [self.sceneView.session pause];
}

#pragma mark - Unit Functions
- (void)addAnchorButtonEvent:(UIButton *)sender
{
    if (sender.tag == 1001)
    {
        if (m_planeArr.count == 0) {
            [m_SpaceLab setText:@"没有找到平面"];
            return;
        }
        if (!m_isMeasuring) {
            m_isMeasuring = YES;
            m_VectorStart = SCNVector3Zero;
            m_VectorEnd = SCNVector3Zero;
            if (m_lineCon) {
                [m_lineCon removeLine];
            }
        }
        else
        {
            m_isMeasuring = NO;
            SCNMaterial *material = [SCNMaterial material]; // material 渲染器
            material.diffuse.contents = [UIColor redColor];
            SCNCone *coneNode = [SCNCone coneWithTopRadius:.005 bottomRadius:.001 height:0.02];//创建一个椎体
            coneNode.materials = @[material];
            SCNNode *startNode = [SCNNode nodeWithGeometry:coneNode];//创建节点
            startNode.position = SCNVector3Make(m_VectorEnd.x, m_VectorEnd.y+0.01, m_VectorEnd.z);
            [self.sceneView.scene.rootNode addChildNode:startNode];
        }
    }
    else
    {
        m_isMeasuring = NO;
        m_VectorStart = SCNVector3Zero;
        m_VectorEnd = SCNVector3Zero;
        if (m_lineCon) {
            [m_lineCon removeLine];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)scanWorld
{
    SCNVector3 worldPostion = SCNVector3Zero;
    worldPostion = [self.sceneView worldVectorFromPosition:self.view.center];
    if ([SCNVector3Tool isEqualBothSCNVector3WithLeft:worldPostion Right:SCNVector3Zero]) {
        return;
    }
    if (m_planeArr.count == 0) {
        [m_SpaceLab setText:@"没有找到平面"];
        return;
    }
    else
    {
        worldPostion = [self.sceneView planeExtentFromPosition:self.view.center];
        if (!m_isMeasuring)
        {
            [m_SpaceLab setText:@"可以开始测量"];
        }
        NSLog(@"worldPostion = %@", [NSValue valueWithSCNVector3:worldPostion]);
        if ([SCNVector3Tool isEqualBothSCNVector3WithLeft:worldPostion Right:SCNVector3Zero]) {
            [m_SpaceLab setText:@"焦点不在平面内"];
            return;
        }
    }
    [m_FocusNode setPosition:SCNVector3Make(worldPostion.x, worldPostion.y+0.01, worldPostion.z)];
    if (m_isMeasuring)
    {
        if ([SCNVector3Tool isEqualBothSCNVector3WithLeft:m_VectorStart Right:SCNVector3Zero]) {
            m_VectorStart = worldPostion;
            m_lineCon = [[LineController alloc] initWithSceneView:self.sceneView StartVector:m_VectorStart LengthUnit:Enum_LengthUnit_cenitMeter];
            SCNMaterial *material = [SCNMaterial material]; // material 渲染器
            material.diffuse.contents = [UIColor redColor];
            SCNCone *coneNode = [SCNCone coneWithTopRadius:.005 bottomRadius:.001 height:0.02];//创建一个椎体
            coneNode.materials = @[material];
            SCNNode *startNode = [SCNNode nodeWithGeometry:coneNode];//创建节点
            startNode.position = SCNVector3Make(m_VectorStart.x, m_VectorStart.y+0.01, m_VectorStart.z);
            [self.sceneView.scene.rootNode addChildNode:startNode];
        }
        m_VectorEnd = worldPostion;
        [m_lineCon updateLineContentWithVector:m_VectorEnd];
        [m_SpaceLab setText:[m_lineCon getDistanceWithVector:m_VectorEnd]];
    }
}

#pragma mark - ARSCNViewDelegate

/*
// Override to create and configure nodes for anchors added to the view's session.
- (SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor {
    SCNNode *node = [SCNNode new];
 
    // Add geometry to the node...
 
    return node;
}
*/

- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    SCNVector3 extent = [SCNVector3Tool positionExtent:((ARPlaneAnchor *)anchor).extent];
    if ([SCNVector3Tool isEqualBothSCNVector3WithLeft:extent Right:SCNVector3Zero]) {
        return;
    }
    PlaneNode *planeNode = [[PlaneNode alloc] initWithPlaneAnchor:(ARPlaneAnchor *)anchor];//创建节点
    [node addChildNode:planeNode];
    [m_planeArr setObject:planeNode forKey:anchor.identifier];
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    SCNVector3 extent = [SCNVector3Tool positionExtent:((ARPlaneAnchor *)anchor).extent];
    if ([SCNVector3Tool isEqualBothSCNVector3WithLeft:extent Right:SCNVector3Zero]) {
        return;
    }
    
    PlaneNode *planeNode = [m_planeArr objectForKey:anchor.identifier];
    [planeNode updateNodeWithPlaneAnchor:(ARPlaneAnchor *)anchor];
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    PlaneNode *planeNode = [m_planeArr objectForKey:anchor.identifier];
    [planeNode removeFromParentNode];
    [m_planeArr removeObjectForKey:anchor.identifier];
}

- (void)renderer:(id<SCNSceneRenderer>)renderer updateAtTime:(NSTimeInterval)time
{
    [self performSelectorOnMainThread:@selector(scanWorld) withObject:nil waitUntilDone:NO];
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    NSLog(@"Present an error message to the user error = %@",error);
    [m_SpaceLab setText:@"didFailWithError 错误"];
}

- (void)sessionWasInterrupted:(ARSession *)session {
    NSLog(@"Inform the user that the session has been interrupted, for example, by presenting an overlay");
    [m_SpaceLab setText:@"sessionWasInterrupted 中断"];
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    NSLog(@"Reset tracking and/or remove existing anchors if consistent tracking is required");
    [m_SpaceLab setText:@"sessionInterruptionEnded 结束"];
}

@end

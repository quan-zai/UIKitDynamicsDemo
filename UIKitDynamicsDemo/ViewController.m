//
//  ViewController.m
//  UIKitDynamicsDemo
//
//  Created by 权仔 on 16/6/13.
//  Copyright © 2016年 XZQ. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

/**
 *  容器
 */
@property (nonatomic, strong) UIDynamicAnimator *animator;

/**
 *  物体
 */
@property (nonatomic, strong) UIView *aView;

@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavior;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*
     *  UIDynamicItem：用来描述一个力学物体的状态，其实就是实现了UIDynamicItem委托的对象，或者抽象为有面积有旋转的质点；
     *  UIDynamicBehavior：动力行为的描述，用来指定UIDynamicItem应该如何运动，即定义适用的物理规则。一般我们使用这个类的子类对象来对一组UIDynamicItem应该遵守的行为规则进行描述；
     *  UIDynamicAnimator；动画的播放者，动力行为（UIDynamicBehavior）的容器，添加到容器内的行为将发挥作用；
     *  ReferenceView：等同于力学参考系，如果你的初中物理不是语文老师教的话，我想你知道这是啥..只有当想要添加力学的UIView是ReferenceView的子view时，动力UI才发生作用。
     */
    
    _aView = [[UIView alloc] initWithFrame:CGRectMake(100, 50, 100, 100)];
    _aView.backgroundColor = [UIColor lightGrayColor];
    
    UIPanGestureRecognizer *panViewGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(viewPanGesture:)];
    
    [_aView addGestureRecognizer:panViewGesture];
    
//    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]  initWithTarget:self action:@selector(panGesture:)];
//    [self.view addGestureRecognizer:panGesture];
//    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
//    
//    [self.view addGestureRecognizer:tapGesture];
//    
    [self.view addSubview:_aView];
    
    // 给aView添加一个旋转角度
    _aView.transform = CGAffineTransformRotate(_aView.transform, 45);
    
    // 以现在的VC的View为参考系（referenceView）
    _animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    // 1.对aView添加重力行为
    UIGravityBehavior *gravityBeahvior = [[UIGravityBehavior alloc] initWithItems:@[_aView]];
    
    // 改变物体密度
    gravityBeahvior.magnitude = 10;
    
    [_animator addBehavior:gravityBeahvior];
    
    // 2.对aView添加碰撞行为
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[_aView]];
    
    // 以整个参考系的边框作为碰撞边界
    /*
     （另外你还可以使用setTranslatesReferenceBoundsIntoBoundaryWithInsets:这样的方法来设定某一个区域作为碰撞边界，更复杂的边界可以使用addBoundaryWithIdentifier:forPath:来添加UIBezierPath，或者addBoundaryWithIdentifier:fromPoint:toPoint:来添加一条线段为边界，详细地还请查阅文档）；
     另外碰撞是有回调的，可以在self中实现UICollisionBehaviorDelegate。
     */
    collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [_animator addBehavior:collisionBehavior];
    
    // 碰撞的回调
//    collisionBehavior.collisionDelegate = self;
    
    /*
     UIAttachmentBehavior 描述一个view和一个锚相连接的情况，也可以描述view和view之间的连接。attachment描述的是两个点之间的连接情况，可以通过设置来模拟无形变或者弹性形变的情况（再次希望你还记得这些概念，简单说就是木棒连接和弹簧连接两个物体）。当然，在多个物体间设定多个；UIAttachmentBehavior，就可以模拟多物体连接了..有了这些，似乎可以做个老鹰捉小鸡的游戏了- -…
     UISnapBehavior 将UIView通过动画吸附到某个点上。初始化的时候设定一下UISnapBehavior的initWithItem:snapToPoint:就行，因为API非常简单，视觉效果也很棒，估计它是今后非游戏app里会被最常用的效果之一了；
     UIPushBehavior 可以为一个UIView施加一个力的作用，这个力可以是持续的，也可以只是一个冲量。当然我们可以指定力的大小，方向和作用点等等信息。
     UIDynamicItemBehavior 其实是一个辅助的行为，用来在item层级设定一些参数，比如item的摩擦，阻力，角阻力，弹性密度和可允许的旋转等等
     UIDynamicItemBehavior有一组系统定义的默认值，
     
     allowsRotation YES // 是否允许旋转
     density 1.0      // 密度
     elasticity 0.0   // 弹性
     friction 0.0     // 摩擦力
     resistance 0.0   // 阻力
     */
}

#pragma mark - gesture -

- (void)panGesture:(UIPanGestureRecognizer *)panGesture
{
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        
//        [_animator removeAllBehaviors];
        
        CGPoint location = [panGesture locationInView:self.view];
        CGPoint boxLocation = [panGesture locationInView:_aView];
        
        UIOffset centerOffset = UIOffsetMake(boxLocation.x - CGRectGetMinX(_aView.bounds), boxLocation.y - CGRectGetMinY(_aView.bounds));
        
        _attachmentBehavior =
        [[UIAttachmentBehavior alloc] initWithItem:_aView
                                  offsetFromCenter:centerOffset  // 吸附的偏移量
                                  attachedToAnchor:location];    // 锚点
//        UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:_aView attachedToAnchor:boxLocation];
        
        _attachmentBehavior.damping = 0.2;
        _attachmentBehavior.frequency = 0.8;
        [_animator addBehavior:_attachmentBehavior];
        
    } else if (panGesture.state == UIGestureRecognizerStateChanged) {
        [_attachmentBehavior setAnchorPoint:[panGesture locationInView:self.view]];
    } else if (panGesture.state == UIGestureRecognizerStateEnded) {
        [_animator removeBehavior:_attachmentBehavior];
    }
}

- (void)tapGesture:(UITapGestureRecognizer *)gesture
{
    [_animator removeAllBehaviors];
    
    CGPoint tapPoint = [gesture locationInView:self.view];
    
    // 捕捉行为
    UISnapBehavior *snapBehavior = [[UISnapBehavior alloc] initWithItem:_aView snapToPoint:tapPoint];
    snapBehavior.damping = 0.8f;  //剧列程度
    [_animator addBehavior:snapBehavior];
}

- (void)viewPanGesture:(UIPanGestureRecognizer *)gesture
{
    [_animator removeAllBehaviors];
    
    CGPoint velocity = [gesture velocityInView:self.view];
    CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
    
//    if (magnitude > ThrowingThreshold) {
        //2
        UIPushBehavior *pushBehavior = [[UIPushBehavior alloc]
                        initWithItems:@[_aView]
                        mode:UIPushBehaviorModeInstantaneous];
        pushBehavior.pushDirection = CGVectorMake((velocity.x / 10) , (velocity.y / 10));
        pushBehavior.magnitude = magnitude / 5;
        
        
        [_animator addBehavior:pushBehavior];
        
        //3
        //                UIDynamicItemBehavior 其实是一个辅助的行为，用来在item层级设定一些参数，比如item的摩擦，阻力，角阻力，弹性密度和可允许的旋转等等
        NSInteger angle = arc4random_uniform(20) - 10;
        
        UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[_aView]];
        itemBehavior.friction = 1000;
        itemBehavior.resistance = 10000;
        itemBehavior.allowsRotation = YES;
        [itemBehavior addAngularVelocity:angle forItem:_aView];
        [_animator addBehavior:itemBehavior];
        
        //4
//        [self performSelector:@selector(resetDemo) withObject:nil afterDelay:0.4];
//    }
}

@end

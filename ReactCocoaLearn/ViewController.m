//
//  ViewController.m
//  ReactCocoaLearn
//
//  Created by 随风流年 on 2020/3/24.
//  Copyright © 2020 随风流年. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC.h>
#import <ReactiveObjC/NSObject+RACKVOWrapper.h>

#import <ReactiveCocoa-Swift.h>

#import "Person.h"

@interface ViewController ()
@property (nonatomic, strong)   UIView      *greenView;
@property (nonatomic, strong)   UIButton    *button;
@property (nonatomic, strong)   UITextField *textFiled;
@property (nonatomic, strong)   UILabel     *label;
@property (nonatomic, strong)   RACSignal   *racsignal;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    /**
    ReactiveCocoa常见类
       1.RACSignal: 信号类，一般表示将来有数据传递，只要有数据改变，信号内部接收到数据
    就会马上发出数据，信号类（RACSignal），只是表示当数据改变时，信号内部会发出数据，它本身
    不具备发送信号的能力，而是交给内部一个订阅者去发出。
       2.默认一个信号都是冷信号，也就是值改变了，也不会触发，
    只有订阅了这个信号，这个信号才会变为热信号，值改变了才会触发
       3. 如何订阅信号：调用信号RACSignal的subscribeNext就能订阅
    
    */
    
    // RACSignal的使用步骤：1.创建信号 2.订阅信号  3.发送信号
    //1.创建一个信号（冷信号）
//    RACSignal *racsignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
//       // didSubscribe调用：只要一个信号被订阅就会被调用
//        //didSubscribe的作用：发送数据
//        //3.发送数据
//        [subscriber sendNext:@1];
//        return nil;
//    }];
//    //2.订阅信号（热信号）
//    [racsignal subscribeNext:^(id  _Nullable x) {
//       //nextBlock调用：只要订阅者发送数据就会被调用
//        // nextBlock的作用：处理数据，展示到UI上面
//        //4.发送信号
//        NSLog(@"log= %@",x);
//    }];
    
    /* RACSignal 底层实现：
     1. 创建信号，首先把didSubscirbe保存到信号中，还不会触发
     2. 当信号被订阅，也就是调用signal的subscribeNext:nextBlock
     2.2 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中
     2.3 subscribeNext内部会调用signal的didSubscribe
     3. signal的didSubscribe 中调用[subscriber sendNext:@1];
     3.1 sendNext底层其实就是执行subscriber的nextBlock
     */
    
    //1,创建信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
       //block调用时刻，每当有订阅者订阅信号，就会调动block
        //2. 发送信号
        [subscriber sendNext:@1];
        //如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅号
        [subscriber sendCompleted];
        return [RACDisposable disposableWithBlock:^{
            //block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block，取消订阅信号
            //执行完block后，当前信号就不在被订阅了
            NSLog(@"信号被销毁");
        }];
    }];
    //3. 订阅信号，才会激活信号
    [signal subscribeNext:^(id  _Nullable x) {
       //block调用时刻：每当有信号发出数据，就会调用block
        NSLog(@"接收的数据：%@",x);
    }];
    /*
     RACSubscriber表示订阅者的意思，用于发送信号，这是一个协议
     不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者，通过
     create创建信号，都有一个订阅者帮助他发送数据
     
     RACDisposable：用于取消订阅或者清理资源，当信号发送完成或者
     发送错误的时候，就会自动触发它，使用场景：不想监听某个信号时，
     可以通过它主动取消订阅信号
     */
    //RACSubject
    /*
     RACSubject:信号提供者，自己可以充当信号，又能发送信号
     使用场景，通常用来代替代理，有了它，就不必要定义代理了
     */
    //1.创建信号
    RACSubject *subject = [RACSubject subject];
    //2.订阅信号
    //2.1 不同的信号处理方式不一样
    //2.2 RACSubject处理订阅：仅仅是保存订阅者
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"发送信号的内容：%@",x);
    }];
    //3.发送信号
    [subject sendNext:@"123"];
    //3.1 底层实现：遍历所有的订阅者，调用nextBlock
    //执行流程
    //3.2 RACSubject被订阅，仅仅是保存订阅者
    //3.3 RACSubject发送数据，遍历所有的订阅者，调用他们的nextBlock
    
    //RACReplaySubject：重复提供信号类，RACSubject的子类
    //1. 创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    //2. 创建订阅者
    [replaySubject subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅信号");
    }];
    // 3.发送订阅者信号
    [replaySubject sendNext:@"123"];
    //RACReplaySubject发送数据
    //1.保存值
    //2.遍历所有的订阅者，发送数据
    //注意：RACReplaySubject：可以先发送信号，再订阅信号
    /*
     1.创建信号【RACSubject subject】跟RACSignal不一样，创建信号时没有block
     2.可以先订阅信号，也可以先发送信号
     2.1 订阅信号 -（RACDisposable *）subscribeNext:(void(^)(id x))nextBlock;
     2.2 发送信号 sendNext:(id)value
     
     RACReplaySubject：底层实现和RACSubject不一样
     1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者
     一个一个调用订阅者的nextBlock
     2.调用subscribeNext订阅信号，遍历保存所有值，一个一个调用订阅者的nextBlock
     
     */
    //1.创建信号
    RACReplaySubject *repSubject  = [RACReplaySubject subject];
    //2.发送信号
    [repSubject sendNext:@1];
    [repSubject sendNext:@2];
    //3.订阅信号
    [repSubject subscribeNext:^(id  _Nullable x) {
        NSLog(@"第一个订阅者接收到的数据：%@",x);
    }];
    [repSubject subscribeNext:^(id  _Nullable x) {
        NSLog(@"第二个订阅者接收到的数据：%@",x);
    }];
    /*
     RACReplaySubject 与 RACSubject区别：RACReplaySubject可以先发送信号，再订阅信号
     RACSubject就不可以
     使用场景：如果一个信号每被订阅一次，就需要把之前的值重发送一遍，使用重复提供信号类
     使用场景二：可以设置capacity数量来限制缓存的value的数量，即只缓存最新的几个值
     
     */
    
//    RACTuple:元组类，类似于NSArray,用来包装值
    RACTuple *arcTUple = [RACTuple tupleWithObjectsFromArray:@[@1,@2,@3]];
    NSLog(@"打印：%@",arcTUple[0]);
    
    //RACSequence：集合类
    //RACSequence:RAC中的集合类，用于代替NSArray，NSDictionary可以使用它来快速遍历数组和字典
    NSArray *array = @[@1,@2,@3,@4];
    //2.数组转RAC集合
    RACSequence  *sequence = array.rac_sequence;
    //3.把集合转化为信号
    RACSignal *arraySignal = sequence.signal;
    //4.订阅集合信号，内部会自动遍历所有的元素发出来
    [arraySignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"第一种方式-%@",x);
    }];
    //第二种放肆
    [array.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"第二种方式：%@",x);
    }];
    
    //1.遍历数组
    NSArray *numbers = @[@1,@2,@3,@4];
    /*这里其实是三步：
     第一步:把数组转换成集合RACSequence numbers.rac_sequence
     第二步：把集合RACSequence转换成RACSignal信号类，numbers.rac_sequence.signal
     第三步：订阅信号，激活信号，会自动把集合中的所有值，遍历出来
     */
    [numbers.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"遍历数组：%@",x);
    }];
    //遍历字典，遍历出来的键值对会包装成RACTuple（元祖对象）（可变字典和不可变字典都可以）
    //1.创建字典
    NSDictionary *dictionary = @{@"A":@"1",@"B":@"2",@"C":@"3"};
    //2.转化成集合
    [dictionary.rac_sequence.signal subscribeNext:^(RACTuple  * _Nullable  x) {
        /**
         普通用法
         */
//        NSString *key = x[0];
//        NSString *value = x[1];
//        NSLog(@"key=%@ value=%@",key,value);
        /**
         高级用法
         */
        RACTupleUnpack(NSString *key,NSString *value) = x;
        NSLog(@"key:%@ value:%@",key,value);
    }];
    
    //字典转模型
    NSMutableArray *dataArray = [NSMutableArray array];
    NSArray *dicArray =  @[@{@"name":@"张三"},@{@"age":@"2"},@{@"height":@"180"}];
    [dicArray.rac_sequence.signal subscribeNext:^(NSDictionary *  _Nullable x) {
        //这里的操作是在子线程中操作的
        Person *person = [Person modelWithDictionary:x];
        [dataArray addObject:person];
    }];
    NSLog(@"dataArray:%@",dataArray);
    //2. 高级用法
    NSArray *arr = [[dicArray.rac_sequence map:^id _Nullable(id  _Nullable value) {
        //这里是在主线程操作的,value：集合中的元素 id：返回对象就是映射的值
        return [Person modelWithDictionary:value];
    }]array];
    NSLog(@"arr:%@",arr);
    
    //ReactiveCocoa开发中常见用法
    //1.代替代理
    UIView *greenView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    greenView.backgroundColor = UIColor.greenColor;
    greenView.frame = CGRectMake(100, 100, 100, 30);
    [self.view addSubview:greenView];
    self.greenView = greenView;

    ///第一种监听方法（可以传参数）
//    subject:监听方法(可以传送参数)
    //1.在对象里面建立RACSubject对象,在调用方法里面发送信号
    //2.创建订阅者:self.redView是一个类的对象
//    [greenView.subject subscribeNext:^(id x){
//
//    }];
    //第二种监听方法（不能传递参数）
    [[greenView rac_signalForSelector:@selector(sender:)] subscribeNext:^(RACTuple * _Nullable x) {
        
    }];
    
    //2.代替KVO
    //1.第一种代替KVO NSObject+RACKVOWrapper.h 类里面的方法监听
    [self.greenView rac_observeKeyPath:@"frame" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
        NSLog(@"被调用");
    }];
    //第二种代替KVO，默认会先走一次
    [[self.greenView rac_valuesForKeyPath:@"frame" observer:nil]subscribeNext:^(id  _Nullable x) {
        NSLog(@"改变的值：%@",x);
    }];
    
    //3.监听事件
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setTitle:@"按钮" forState:UIControlStateNormal];
    self.button.backgroundColor = UIColor.purpleColor;
    self.button.frame = CGRectMake(100, 200, 100, 30);
    [self.view addSubview:self.button];
    /**
     创建信号并订阅
     */
    [[self.button rac_signalForControlEvents:UIControlEventTouchUpInside]subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"你点击了按钮");
    }];
    
    self.textFiled = [[UITextField alloc]init];
    self.textFiled.frame = CGRectMake(100, 250, 100, 30);
    self.textFiled.backgroundColor = UIColor.redColor;
    [self.view addSubview:self.textFiled];
    
    //4. 代替通知
    //把监听到的通知转换为信号
    [[[NSNotificationCenter defaultCenter]rac_addObserverForName:UIKeyboardWillShowNotification object:nil]subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"键盘弹出");
    }];
    
    //监听文本的变化
    [self.textFiled.rac_textSignal subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"变化的值：%@",x);
    }];
    
    //总结：
    /*
     1.信号类：表示有数据产生
     */
    //处理多个请求，都返回结果的时候，统一做处理
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
       //发送请求1
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
       //发送请求2
        [subscriber sendNext:@"发送请求2"];
        return nil;
    }];
    //使用注意：几个信号，参数1的方法就几个参数，每个参数对应信号发出的数据
    [self rac_liftSelector:@selector(updateUIWithR1:r2:) withSignalsFromArray:@[request1,request2]];
    self.label = [[UILabel alloc]initWithFrame:CGRectMake(100, 300, 100, 30)];
    [self.view addSubview:self.label];
    
    //9.RAC中常用的宏
    //RAC(RAEGET,...)用来给某个对象的属性绑定信号，只要产生信号内容，就会给属性赋值
    RAC(_label,text) = _textFiled.rac_textSignal;
    
    //RACObserve(控件对象，属性)：监听某个对象的某个属性，返回的是信号，只要这个对象的属性一改变就会产生信号
    [RACObserve(self.greenView, frame) subscribeNext:^(id  _Nullable x) {
        NSLog(@"frame：%@",x);

    }];
    [RACObserve(self.view, center) subscribeNext:^(id  _Nullable x) {
        NSLog(@"中心店：%@",x);
    }];
    //@weakify(Obj)和strongify(Obj)一般两个都是配套使用，解决循环引用问题
    @weakify(self);
    RACSignal *racsignal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        @strongify(self);
        NSLog(@"-----%@",self);
        return nil;
    }];
    _racsignal = racsignal;
    
    // RACTuplePack:把数据包装成RACTuple(元祖类)
    RACTuple *tuple = RACTuplePack(@10,@20);
    RACTupleUnpack(NSNumber *number1,NSNumber *number2) = tuple;
    
    
    //10.RACMulticastConnection：解决重复请求的问题
    /*
     RACMulticastConnection:用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理。
     注意：RACMulticastConnection通过RACSignal的-publish或者-muticast：方法创建
     RACMulticastConnection简单使用
     1.创建信号： +(RACSignal*)createSignal:(RACDisposable *(^)(id<RACSubscriber>subscriber))didSubscribe
     2.创建连接：RACMulticastConnection *connect = [signal publish];
     3.订阅信号，注意：订阅的不在是之前的信号，而是连接的信号 [connect.signal subscribeNext:nextBlock]
     4.连接：[connect connect]
     */
    
}
- (void)updateUIWithR1:(id)data r2:(id)data1{
    NSLog(@"更新UI；%@ %@",data,data1);
}
- (void)dealloc{
    NSLog(@"%s",__func__);
}

@end

















































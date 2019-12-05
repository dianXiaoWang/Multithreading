//
//  ViewController.m
//  ThreadTest
//
//  Created by Wang on 2019/11/20.
//  Copyright © 2019 Wang. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>
@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *testImageView;

@property (nonatomic,assign) NSInteger number;

@property (nonatomic,strong) UIImage *firstImage;

@property (nonatomic,strong) UIImage *secondImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.number = 18;
//    [self performSelectorInBackground:@selector(test) withObject:@"隐式"];
//  [self pthread];
//  [self nsThread];
//    [self GCD];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//    [NSThread performSelectorInBackground:@selector(downLoadImage) withObject:@"image"];
//    [NSThread detachNewThreadSelector:@selector(downLoadImage) toTarget:self withObject:@"image"];
//    [self GCDTest];
//    [self barrier];
//    [self operation];
    [self operationTest];
}

#pragma pthread
-(void)pthread{
    
    // 创建线程
    pthread_t thred;
    /*
     第一个参数pthread_t *restrict:线程对象
     第二个参数const pthread_attr_t *restrict:线程属性
     第三个参数void *(*)(void *) :指向函数的指针
     第四个参数void *restrict:函数的参数
    */
    pthread_create(&thred,NULL,run,NULL);
}

void *(run)(void *param){
    
    for (int i = 0;i < 3;i++){
        NSLog(@"%@",[NSThread currentThread]);
    }
    return NULL;
}


#pragma NSThread
-(void)nsThread{
    
    NSThread *threadOne = [[NSThread alloc] initWithTarget:self selector:@selector(test) object:@"NSThread"];
    [threadOne setName:@"threadOne"];
    threadOne.threadPriority = 0.1;
    // 线程开启
    [threadOne start];

    NSThread *threadTwo = [[NSThread alloc] initWithTarget:self selector:@selector(test) object:@"threadTwo"];
    [threadTwo setName:@"threadTwo"];
    threadTwo.threadPriority = 0.1;
    [threadTwo start];

    NSThread *threadThree = [[NSThread alloc] initWithTarget:self selector:@selector(test) object:@"threadThree"];
    [threadThree setName:@"threadThree"];
    threadThree.threadPriority = 0.1;
    [threadThree start];
    
    // 创建线程后自动开启
    [NSThread detachNewThreadSelector:@selector(test) toTarget:self withObject:@"自动"];
    [NSThread detachNewThreadSelector:@selector(test) toTarget:self withObject:@"自动"];
    [NSThread detachNewThreadSelector:@selector(test) toTarget:self withObject:@"自动"];

    // 隐式创建并自动启动
    [self performSelectorInBackground:@selector(test) withObject:@"隐式"];
    [self performSelectorInBackground:@selector(test) withObject:@"隐式"];
    [self performSelectorInBackground:@selector(test) withObject:@"隐式"];
}

// 互斥锁,保证数据的安全
-(void)test{
    while (1) {
        @synchronized (self) {
            [NSThread setThreadPriority:0.02];
            if (self.number > 0) {
                self.number -= 1;
                      NSLog(@"剩余票数%ld",self.number);
            }else{
                NSLog(@"没有票了");
                break;
            }
        }
    }
    // 回到主线程
    [self performSelectorOnMainThread:@selector(performOnMainThread) withObject:@"1" waitUntilDone:YES];
}

// 子线程执行完成后返回主线程
-(void)performOnMainThread{
    
    NSLog(@"回到主线程%@",[NSThread currentThread]);
}

-(void)downLoadImage{
    
    NSURL *url = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574748758519&di=602adc4e663ee8e88acba1dedd8b0ade&imgtype=0&src=http%3A%2F%2Fwow.tgbus.com%2FUploadFiles_2396%2F201201%2F20120115111232552.jpg"];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    [self performSelectorOnMainThread:@selector(showImage:) withObject:image waitUntilDone:YES];
}

-(void)showImage:(UIImage *)image{
    self.testImageView.image = image;
}

#pragma GCD
-(void)GCD{
    // 队列在任务中，任务在block中。开启异步函数   等主线程执行完毕再开启子线程执行任务
    // 并发队列
    dispatch_queue_t  queue = dispatch_queue_create("并发", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t  queuee= dispatch_get_global_queue(0, 0);
    /*
        1、dispatch_queue_create("并发", DISPATCH_QUEUE_CONCURRENT);
        2、dispatch_get_global_queue(0, 0)
        这两个都是并发队列，dispatch_queue_create这个是自己再创建，dispatch_get_global_queue这个则是使用GCD默认提供的全局并发队列，共整个应用创建，不需要自己创建
    */
    // 串行队列
    dispatch_queue_t  que   = dispatch_queue_create("串行", DISPATCH_QUEUE_SERIAL);
    
    // 并发队列+异步函数 任务并发执行
    dispatch_async(queue, ^{
        NSLog(@"-----并发队列+异步函数+会开启新线程-----%@",[NSThread currentThread]);
    });
    // 并发队列+同步函数 任务串行执行
    dispatch_sync(queuee, ^{
        NSLog(@"-----并发队列+同步函数+不会开启新线程-----%@",[NSThread currentThread]);
    });
    // 串行队列+异步函数 任务串行执行
    dispatch_async(que, ^{
        NSLog(@"-----串行队列+异步函数+会开启新线程-----%@",[NSThread currentThread]);
    });
    // 串行队列+同步函数 任务串行执行
    dispatch_sync(que, ^{
        NSLog(@"-----串行队列+同步函数+不会开启新线程-----%@",[NSThread currentThread]);
    });
    // 主队列+异步函数   在主线程任务串行执行
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"-----主队列+异步函数+不会开启新线程-----%@",[NSThread currentThread]);
    });
    // 主队列+同步函数 任务串行执行
    // **************** 系统维护的dispatch_get_main_queue在本方法内，是先进栈的，需要执行完本方法后，再执行自己创建的dispatch_get_main_queue的block内的方法，但是系统维护的dispatch_get_main_queue又需要等待自己创建dispatch_sync同步函数的dispatch_get_main_queue的block内的方法执行完成才能继续执行，而自己创建的dispatch_get_main_queue在等待系统维护的dispatch_get_main_queue执行完成，出现了相互等待
    // ****注意死锁****
    dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"-----主队列+同步函数-----%@",[NSThread currentThread]);
      });
    // 如果想要使用的，开辟线程后再使用
    dispatch_async(queue, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
           NSLog(@"-----主队列+同步函数-----%@",[NSThread currentThread]);
        });
    });
 
    
}

-(void)GCDTest{
    
    dispatch_queue_t que = dispatch_queue_create("异步函数",DISPATCH_QUEUE_SERIAL);
    // 同步函数+并发队列 顺序执行
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"---同步并发下载One---%@",[NSThread currentThread]);
    });
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
         NSLog(@"---同步并发下载Two---%@",[NSThread currentThread]);
     });
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
         NSLog(@"---同步并发下载Three---%@\n",[NSThread currentThread]);
     });
    // 同步函数+串行队列 顺序执行
    dispatch_sync(que, ^{
         NSLog(@"---同步串行下载One---%@",[NSThread currentThread]);
    });
    dispatch_sync(que, ^{
         NSLog(@"---同步串行下载Two---%@",[NSThread currentThread]);
    });
    dispatch_sync(que, ^{
         NSLog(@"---同步串行下载Three---%@\n",[NSThread currentThread]);
    });
    // 异步函数+并发队列 随机执行
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"---异步并发下载One---%@",[NSThread currentThread]);
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"---异步并发下载Two---%@",[NSThread currentThread]);
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"---异步并发下载Three---%@\n",[NSThread currentThread]);
    });
    // 异步函数+串行队列 顺序执行
    dispatch_async(que, ^{
        NSLog(@"---异步串行下载One---%@",[NSThread currentThread]);
    });
    dispatch_async(que, ^{
        NSLog(@"---异步串行下载Two---%@",[NSThread currentThread]);
     });
    dispatch_async(que, ^{
        NSLog(@"---异步串行下载Three---%@\n",[NSThread currentThread]);
     });
    // 异步函数的并发队列，开辟多个子线程随机顺序执行。串行队列，开辟一个子线程，顺序执行
    // 测试
    dispatch_async(que, ^{
        NSURL *url = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574748758519&di=602adc4e663ee8e88acba1dedd8b0ade&imgtype=0&src=http%3A%2F%2Fwow.tgbus.com%2FUploadFiles_2396%2F201201%2F20120115111232552.jpg"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:data];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.testImageView.image = image;
        });
    });
}

// 栅栏函数
-(void)barrier{
    
    dispatch_queue_t queue = dispatch_queue_create("栅栏函数",DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"%d-download1--%@",i,[NSThread currentThread]);
        }
    });
    
    dispatch_async(queue, ^{
        for (int i = 0; i < 3; i++) {
            NSLog(@"%d-download2--%@",i,[NSThread currentThread]);
        }
    });
    
    // 测试
     dispatch_async(queue, ^{
         NSURL *url = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574748758519&di=602adc4e663ee8e88acba1dedd8b0ade&imgtype=0&src=http%3A%2F%2Fwow.tgbus.com%2FUploadFiles_2396%2F201201%2F20120115111232552.jpg"];
         NSData *data = [NSData dataWithContentsOfURL:url];
         UIImage *image = [UIImage imageWithData:data];
         dispatch_async(dispatch_get_main_queue(), ^{
             self.testImageView.image = image;
         });
     });
    
    // 栅栏函数进行阻断
    dispatch_barrier_sync(queue, ^{
        NSLog(@"我要拦截，上面线程执行完成之后，下面再执行");
    });
    
    dispatch_async(queue, ^{
         for (int i = 0; i < 3; i++) {
             NSLog(@"%d-download3--%@",i,[NSThread currentThread]);
         }
     });
    
    dispatch_async(queue, ^{
         for (int i = 0; i < 3; i++) {
             NSLog(@"%d-download4--%@",i,[NSThread currentThread]);
         }
     });
    
    // 延迟执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0*NSEC_PER_SEC)),dispatch_get_main_queue() ,^{
        NSLog(@"延时2秒");
        self.testImageView.image = nil;
    });
    [self dispatchOnce];
    [self dispatchGroup];
}

// 单利，只执行一次
-(void)dispatchOnce{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"是不是一次");
    });
}

// 队列组
-(void)dispatchGroup{
    
    // 创建队列组
    dispatch_group_t group = dispatch_group_create();
    
    // 创建并发+异步
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        
        NSURL *url = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574748758519&di=602adc4e663ee8e88acba1dedd8b0ade&imgtype=0&src=http%3A%2F%2Fwow.tgbus.com%2FUploadFiles_2396%2F201201%2F20120115111232552.jpg"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.firstImage = [UIImage imageWithData:data];
    });

    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSURL *url = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574748758519&di=602adc4e663ee8e88acba1dedd8b0ade&imgtype=0&src=http%3A%2F%2Fwow.tgbus.com%2FUploadFiles_2396%2F201201%2F20120115111232552.jpg"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.secondImage = [UIImage imageWithData:data];
    });
    
    // 合成
    dispatch_group_notify(group, dispatch_get_global_queue(0, 0), ^{
        //开启图形上下文
        UIGraphicsBeginImageContext(CGSizeMake(200, 200));
        //画1
        [self.firstImage drawInRect:CGRectMake(0, 0, 200, 100)];
        //画2
        [self.secondImage drawInRect:CGRectMake(0, 100, 200, 100)];
        //根据图形上下文拿到图片
        UIImage *image =  UIGraphicsGetImageFromCurrentImageContext();
        //关闭上下文
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
             self.testImageView.image = image;
             NSLog(@"%@--刷新UI",[NSThread currentThread]);
         });
    });
}

#pragma NSOperation
-(void)operation{
    
    // 创建队列
    NSOperationQueue  *queue = [[NSOperationQueue  alloc] init];
    
    // 可以设置最大并发数
    /*
    默认是并发队列，如果最大并发数>1那么就并发。如果最大并发=1那么是串行。系统默认最大并发-1，不限制。设置为0则不执行任何操作，同一时间只能执行三个
    */
    queue.maxConcurrentOperationCount = 1;
    
    // YES的时候暂停，NO恢复
    queue.suspended = YES;
    
    // 取消线程任务，此操作不可逆
    [queue cancelAllOperations];
    // 获取该队列中的操作
    NSLog(@"队列中的操作%@",[queue operations]);
    
    // 队列中的操作数量
    NSLog(@"队列中的操作数量%ld",[queue operationCount]);
    
    // 阻塞当前线程直到当前队列中的任务执行完毕
    [queue waitUntilAllOperationsAreFinished];
    
    NSLog(@"当前线程---%@",[NSThread currentThread]);
    // 回到主线程
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
    
    }];
    
    // 创建线程
    NSOperation *operation = [NSOperation new];
    NSOperation *opDepend  = [NSOperation new];
    
    // 线程开启
    [operation start];
    [opDepend   main];
    // 判断线程是否取消
//    [operation cancel];
    NSLog(@"线程是否取消%d",[operation isCancelled]);
    
    // 任务是否在运行
    NSLog(@"任务是否在运行%d",[operation isExecuting]);
    
    // 任务是否已结束
    NSLog(@"任务是否已结束%d",[operation isFinished]);
    
    // 添加依赖
    [opDepend addDependency:operation];
    
    // 移除依赖
    [opDepend removeDependency:operation];
    
    // 线程名称
    operation.name = @"operation";
    
    NSLog(@"当前线程---%@",[NSThread currentThread]);
    
    // 获取线程优先级
    [operation threadPriority];
    // 阻塞线程
    [operation waitUntilFinished];
    
}

-(void)operationTest{
    
    // 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 3;
    NSBlockOperation *downLoadOne = [NSBlockOperation blockOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574748758519&di=602adc4e663ee8e88acba1dedd8b0ade&imgtype=0&src=http%3A%2F%2Fwow.tgbus.com%2FUploadFiles_2396%2F201201%2F20120115111232552.jpg"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.firstImage = [UIImage imageWithData:data];
        NSLog(@"当前线程1---%@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *downLoadTwo = [NSBlockOperation blockOperationWithBlock:^{
        NSURL *url = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1574748758519&di=602adc4e663ee8e88acba1dedd8b0ade&imgtype=0&src=http%3A%2F%2Fwow.tgbus.com%2FUploadFiles_2396%2F201201%2F20120115111232552.jpg"];
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.secondImage = [UIImage imageWithData:data];
        NSLog(@"当前线程2---%@",[NSThread currentThread]);
    }];
    
    NSBlockOperation *fit = [NSBlockOperation blockOperationWithBlock:^{
        //开启图形上下文
        UIGraphicsBeginImageContext(CGSizeMake(200, 200));
        //画1
        [self.firstImage drawInRect:CGRectMake(0, 0, 200, 100)];
        //画2
        [self.secondImage drawInRect:CGRectMake(0, 100, 200, 100)];
        //根据图形上下文拿到图片
        UIImage *image =  UIGraphicsGetImageFromCurrentImageContext();
        //关闭上下文
        UIGraphicsEndImageContext();
        NSLog(@"当前线程3---%@",[NSThread currentThread]);
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"当前线程4---%@",[NSThread currentThread]);
            self.testImageView.image = image;
        }];
    }];
    
    // 添加线程依赖，图片和成需要两个都下载完成
    [fit addDependency:downLoadOne];
    [fit addDependency:downLoadTwo];
    
    // 添加操作队列
    [queue addOperation:downLoadOne];
    [queue addOperation:downLoadTwo];
    [queue addOperation:fit];

    // 获取该队列中的操作
    NSLog(@"队列中的操作%@",[queue operations]);
    
    // 队列中的操作数量
    NSLog(@"队列中的操作数量%ld",[queue operationCount]);
}
@end

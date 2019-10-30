tcp 的发送流程图

![img](https://yixing.github.io/img/kernel-tcp.gif)

tcp发送涉及到的主要函数

```
    1)sock_write：初始化msghdr{}结构 net/socket.c
    2)sock_sendmsg:net/socket.c
    3)inet_sendmsg:net/ipv4/af_net.c
    4)tcp_sendmsg：申请sk_buff{}结构的空间，把msghdr{}结构中的数据填入sk_buff空间。net/ipv4/tcp.c
    5)tcp_send_skb:net/ipv4/tcp_output.c
    6)tcp_transmit_skb:net/ipv4/tcp_output.c
    7)ip_queue_xmit:net/ipv4/ip_output.c
    8)ip_queue_xmit2:net/ipv4/ip_output.c
    9)ip_output:net/ipv4/ip_output.c
    10)ip_finish_output:net/ipv4/ip_output.c
    11)ip_finish_output2:net/ipv4/ip_output.c
    12)neigh_resolve_output:net/core/neighbour.c
    13)dev_queue_xmit:net/core/dev
```

tcp 的socket操作定义

```c
      static const struct file_operations socket_file_ops = {
        .owner =    THIS_MODULE,                                            
        .llseek =   no_llseek,
        .read_iter =    sock_read_iter,
        .write_iter =   sock_write_iter,                                 
        .poll =     sock_poll,
        .unlocked_ioctl = sock_ioctl,                                    
    #ifdef CONFIG_COMPAT
        .compat_ioctl = compat_sock_ioctl,                     
    #endif
        .mmap =     sock_mmap,
        .release =  sock_close,
        .fasync =   sock_fasync,
        .sendpage = sock_sendpage,
        .splice_write = generic_splice_sendpage,
        .splice_read =  sock_splice_read,                
    }; 
```

## TCP的发送 

发送在write\_iter中, 将file-\>private\_data转换为struct sock*, 然后调用sock->opts->sendmsg()，调用路径

```c
    sock_write_iter > sock_send_msg > sock_sendmsg_nosec
```

sock->opts->sendmsg的函数指针指向 inet\_send\_msg，后者调用对应协议栈的 sk->sk\_prot->setmsg()，在tcp协议中，对应的函数指针是 tcp\_sendmsg，这个函数的主要流程如下

```c
    lock_sock(sk)
    ret = tcp_sendmsg_locked(sk, msg, size);
    release_sock()
```

上锁的操作是先 通过spinlock 锁住 sk->sk\_lock.slock，标记owner后释放，然后调用  mutex\_acquire(&sk->sk\_lock.dep\_map, subclass, 0, \_RET\_IP\_) 这个不知道做什么，之后发送的操作都在tcp\_sendmsg\_lock中进行，函数的主要结构

```c
    if (fastopen) 
        tcp_sendmsg_fastopen()

    if (sk->sk_state not in (TCPF_ESTABLISHED, TCPF_CLOSE_WAIT)) 
        sk_stream_wait_connect()

    mss_now = tcp_send_mss(sk, &size_goal, flags);

    while (msg_data_left(msg)) {
        skb = tcp_write_queue_tail(sk);
        skb = sk_stream_alloc_skb()
        if (!skb)
            goto wait_for_memory;
        skb_entail(sk, skb);

        prepare memory and copy
    }

    tcp_push(sk, flags, mss_now, tp->nonagle, size_goal);
```

在tcp\_send\_msg中，主要做的事情是检查socket的状态，构造skb结构体，然后把数据在skb中组织起来，然后调用tcp\_push()，后者会对tcp的相关flags（MSG\_MORE, MSG\_OOB 带外标记）设置对应的header标记位比如 TCPHDR\_PSH，最终实际的操作交给 tcp\_write\_xmit，调用顺序如下:

```
    tcp_push > __tcp_push_pending_frames > tcp_write_xmit
```

tcp\_write\_xmit 的主要函数结构如下

```c
    while ((skb = tcp_send_head(sk))) {
        if (tcp_pacing_check(sk))
            break

        tcp_transmit_skb()

        tcp_event_new_data_sent(sk, skb);
    }
```

在这个函数中，主要做几个事情

* 检查拥塞控制 tcp\_pacing\_check
* 发送 tcp\_transmit\_skb
* 更新计数 tcp\_event\_new\_data\_sent

先说发送，因为比较简单. tcp\_transmit\_skb 做的事情如下

```c
    tcp_header_size = tcp_options_size + sizeof(struct tcphdr);
    skb_push(skb, tcp_header_size);

    Build TCP header and checksum it.

    err = icsk->icsk_af_ops->queue_xmit(sk, skb, &inet->cork.fl);
```

可以看到做的就是构造header然后交给网络层处理，queue\_xmit对应的是ip层的处理函数 ip\_queue\_xmit    

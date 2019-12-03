# Mutex

# Read Write Lock

# SplinLock

# Semaphore

# Condition

# RCU

sample code in  kernel/Documentation/RCU/whatisRCU.txt:
   
```c
struct foo {
    int a;
};

DEFINE_SPINLOCK(foo_mutex);

struct foo *gbl_foo;

void foo_update_a(int new_a)
{
    struct foo *new_fp;
    struct foo *old_fp;
    new_fp = kmalloc(sizeof(*new_fp), GFP_KERNEL);
    spin_lock(&foo_mutex);
    old_fp = gbl_foo;
    *new_fp = *old_fp;
    new_fp->a = new_a;
    rcu_assign_pointer(gbl_foo, new_fp);
    spin_unlock(&foo_mutex);
    synchronize_rcu();
    kfree(old_fp);
}

int foo_get_a(void)
{
    int retval;
    rcu_read_lock();
    retval = rcu_dereference(gbl_foo)->a;
    rcu_read_unlock();
    return retval;
}
```

async version:

```c
void foo_update_a(int new_a)
{
    struct foo *new_fp;
    struct foo *old_fp;
    new_fp = kmalloc(sizeof(*new_fp), GFP_KERNEL);
    spin_lock(&foo_mutex);
    old_fp = gbl_foo;
    *new_fp = *old_fp;
    new_fp->a = new_a;
    rcu_assign_pointer(gbl_foo, new_fp);
    spin_unlock(&foo_mutex);
    call_rcu(&old_fp->rcu, foo_reclaim);
}

void foo_reclaim(struct rcu_head *rp)
{
    struct foo *fp = container_of(rp, struct foo, rcu);
    foo_cleanup(fp->a);
    kfree(fp);
}
```

If the callback for call\_rcu() is not doing anything more than calling
kfree() on the structure, you can use kfree\_rcu() instead of call\_rcu()
to avoid having to write your own callback:

implementations:

```c
static inline void __rcu_read_lock(void)
{
    preempt_disable();
}

static inline void __rcu_read_unlock(void)
{
    preempt_enable();
}
```


rcu\_assign\_pointer() and rcu\_dereference() are just wrap functions with memory barriers.

```c

synchronize_rcu() > synchronize_sched() > wait_rcu_gp(call_rcu)

void wait_rcu_gp(call_rcu_func_t crf)
{
    struct rcu_synchronize rcu;

    init_rcu_head_on_stack(&rcu.head);
    init_completion(&rcu.completion);
    /* Will wake me after RCU finished. */
    crf(&rcu.head, wakeme_after_rcu);
    /* Wait for it. */
    wait_for_completion(&rcu.completion);
    destroy_rcu_head_on_stack(&rcu.head);
}

```

File Lock

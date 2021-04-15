# 第一节 boltdb事务简介

我们先看一下，boltdb官方文档中对事务的描述：

> Bolt allows only one read-write transaction at a time but allows as many
read-only transactions as you want at a time. Each transaction has a consistent
view of the data as it existed when the transaction started.

> Individual transactions and all objects created from them (e.g. buckets, keys)
are not thread safe. To work with data in multiple goroutines you must start
a transaction for each one or use locking to ensure only one goroutine accesses
a transaction at a time. Creating transaction from the `DB` is thread safe.

> Read-only transactions and read-write transactions should not depend on one
another and generally shouldn't be opened simultaneously in the same goroutine.
This can cause a deadlock as the read-write transaction needs to periodically
re-map the data file but it cannot do so while a read-only transaction is open.


我们再简单总结下，在boltdb中支持两类事务：**读写事务**、**只读事务**。同一时间有且只能有一个读写事务执行；但同一个时间可以允许有多个只读事务执行。每个事务都拥有自己的一套一致性视图。

此处需要注意的是，在boltdb中打开一个数据库时，有两个选项：**只读模式**、**读写模式**。内部在实现时是根据不同的选项来底层加不同的锁(flock)。只读模式对应共享锁，读写模式对应互斥锁。具体加解锁的实现可以在bolt_unix.go 和bolt_windows.go中找到。

提到事务，我们不得不提大家烂熟于心的事务四个特性：ACID。为方便阅读后续的内容，下面再简单回顾一下：

**A(atomic)原子性:**事务的原子性主要表示的是，只要事务一开始(Begin)，那么事务要么执行成功(Commit)，要么执行失败(Rollback)。上述过程只会出现两种状态，在事务执行过程中的中间状态以及数据是不可见的。

**C(consistency)一致性：**事务的一致性是指，事务开始前和事务提交后的数据都是一致的。

**I(isolation)隔离性:**事务的隔离性是指不同事务之间是相互隔离、互不影响的。具体的隔离程度是由具体的事务隔离级别来控制。

**D(duration)持久性:**事务的持久性是指，事务开始前和事务提交后的数据都是永久的。不会存在数据丢失或者篡改的风险。

在此再总结一下：其实上述四大特性中，事务的一致性是终极目标，而其他三大特性都是为了保证一致性而服务的手段。在mysql中，事务的原子性由undo log来保证；事务的持久性由redo log来保证；事务的隔离性由锁来保证。

那具体到boltdb中，它又是如何来实现的呢？

此处以个人的理解来回答下这个问题，理解不一定准确。

首先boltdb是一个文件数据库，所有的数据最终都保存在文件中。当事务结束(Commit)时，会将数据进行刷盘。同时，boltdb通过冗余一份元数据来做容错。当事务提交时，如果写入到一半机器挂了，此时数据就会有问题。而当boltdb再次恢复时，会对元数据进行校验和修复。这两点就保证事务中的**持久性**。

其次boltdb在上层支持多个进程以只读的方式打开数据库，一个进程以写的方式打开数据库。在数据库内部中事务支持两种，读写事务和只读事务。这两类事务是互斥的。同一时间可以有多个只读事务执行，或者只能有一个读写事务执行，上述两类事务，在底层实现时，都是保留一整套完整的视图和元数据信息，彼此之间相互隔离。因此通过这两点就保证了**隔离性**。


在boltdb中，数据先写内存，然后再提交时刷盘。如果其中有异常发生，事务就会回滚。同时再加上同一时间只有一个进行对数据执行写入操作。所以它要么写成功提交、要么写失败回滚。也就支持**原子性**了。

通过以上的几个特性的保证，最终也就保证了**一致性**。




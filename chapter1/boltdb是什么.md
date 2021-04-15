# 第一节 boltdb是什么？


在用自己的话介绍boltdb之前，我们先看下boltdb官方是如何自我介绍的呢？

> Bolt is a pure Go key/value store inspired by [Howard Chu's][hyc_symas]
  [LMDB project][lmdb]. The goal of the project is to provide a simple,
  fast, and reliable database for projects that don't require a full database
  server such as Postgres or MySQL.

>  Since Bolt is meant to be used as such a low-level piece of functionality,
  simplicity is key. The API will be small and only focus on getting values
  and setting values. That's it.

看完了官方的介绍，接下来让我用一句话对boltdb进行介绍：

**boltdb是一个纯go编写的支持事务的文件型单机kv数据库。**

下面对上述几个核心的关键词进行一一补充。

**纯go：** 意味着该项目只由golang语言开发，不涉及其他语言的调用。因为大部分的数据库基本上都是由c或者c++开发的，boltdb是一款难得的golang编写的数据库。

**支持事务：** boltdb数据库支持两类事务：**读写事务**、**只读事务**。这一点就和其他kv数据库有很大区别。

**文件型：** boltdb所有的数据都是存储在磁盘上的，所以它属于文件型数据库。这里补充一下个人的理解，在某种维度来看，boltdb很像一个简陋版的innodb存储引擎。底层数据都存储在文件上，同时数据都涉及数据在内存和磁盘的转换。但不同的是，innodb在事务上的支持比较强大。

**单机：** boltdb不是分布式数据库，它是一款单机版的数据库。个人认为比较适合的场景是，用来做wal日志或者读多写少的存储场景。

**kv数据库：** boltdb不是sql类型的关系型数据库，它和其他的kv组件类似，对外暴露的是kv的接口，不过boltdb支持的数据类型key和value都是[]byte。


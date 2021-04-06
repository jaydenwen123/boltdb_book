# 第二节 boltdb事务Tx定义

```go
// txid represents the internal transaction identifier.
type txid uint64

// Tx represents a read-only or read/write transaction on the database.
// Read-only transactions can be used for retrieving values for keys and creating cursors.
// Read/write transactions can create and remove buckets and create and remove keys.
//
// IMPORTANT: You must commit or rollback transactions when you are done with
// them. Pages can not be reclaimed by the writer until no more transactions
// are using them. A long running read transaction can cause the database to
// quickly grow.
// Tx 主要封装了读事务和写事务。其中通过writable来区分是读事务还是写事务
type Tx struct {
	writable       bool
	managed        bool
	db             *DB
	meta           *meta
	root           Bucket
	pages          map[pgid]*page
	stats          TxStats
	// 提交时执行的动作
	commitHandlers []func()

	// WriteFlag specifies the flag for write-related methods like WriteTo().
	// Tx opens the database file with the specified flag to copy the data.
	//
	// By default, the flag is unset, which works well for mostly in-memory
	// workloads. For databases that are much larger than available RAM,
	// set the flag to syscall.O_DIRECT to avoid trashing the page cache.
	WriteFlag int
}

// init initializes the transaction.
func (tx *Tx) init(db *DB) {
	tx.db = db
	tx.pages = nil

	// Copy the meta page since it can be changed by the writer.
	// 拷贝元信息
	tx.meta = &meta{}
	db.meta().copy(tx.meta)

	// Copy over the root bucket.
	// 拷贝根节点
	tx.root = newBucket(tx)
	tx.root.bucket = &bucket{}
	// meta.root=bucket{root:3}
	*tx.root.bucket = tx.meta.root

	// Increment the transaction id and add a page cache for writable transactions.
	if tx.writable {
		tx.pages = make(map[pgid]*page)
		tx.meta.txid += txid(1)
	}
}
```



# Change log

## 1.0.3 (March 20, 2014)

GENERAL CHANGES

* Change stop signal of (supervised) zookeeper process from KILL to INT.

BUG FIXES

* GH-1: supervisord restart problems when zookeeper-server is killed


## 1.0.2 (March 11, 2014)

BUG FIXES

* Correctly create `$data_dir` recursively.  (Doh!)


## 1.0.1 (March 11, 2014)

IMPROVEMENTS

* Recursively create `$data_dir` if needed.


## 1.0.0 (February 25, 2014)

* Initial release.

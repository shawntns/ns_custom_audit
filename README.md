
# Nessus Custom Audit Use Cases

通过Nessus Custom Audit(自定义基线脚本)实现各类检查， 例如找出各种逻辑复杂的的编译型中间件、Webshell代码等。

* [资产探测脚本](asset_discovery.audit)

## Custom Asset Discovery Java

### 方法论

通过find获取java安装路径并执行java -version得到版本。由于find可能获得多行输出，需要考虑如何将多行输出，作为参数以loop方式传递给“-version”命令处理。
或也可使用xargs

```bash
[root@localhost tmp]# time for bar in `timeout 60s find /  -not -path "/proc/*" -executable -type f -name java 2>/dev/null`; do $bar -version 2>&1; done
openjdk version "1.8.0_201"
OpenJDK Runtime Environment (build 1.8.0_201-b09)
OpenJDK 64-Bit Server VM (build 25.201-b09, mixed mode)

real 0m0.534s
user 0m0.252s
sys 0m0.283s

[root@localhost tmp]# time timeout 60s find /  -not -path "/proc/*" -executable -type f -name java 2>/dev/null | xargs -I % bash -c '% -version'
openjdk version "1.8.0_201"
OpenJDK Runtime Environment (build 1.8.0_201-b09)
OpenJDK 64-Bit Server VM (build 25.201-b09, mixed mode)

real 0m0.549s
user 0m0.269s
sys 0m0.264s
```

### 脚本  

全盘文件检索30秒timeout

```bash
for bar in `timeout 30s find /  -not -path "/proc/*" -not -path "*/docker/*" -executable -type f  -size -10M  -maxdepth 8 -name java 2>/dev/null`; do $bar -version 2>&1; done
```

### 输出样例

```bash
OpenJDK 64-Bit Server VM (build 25.201-b09, mixed mode)
OpenJDK Runtime Environment (build 1.8.0_201-b09)
openjdk version "1.8.0_201"
java version "11" 2018-09-25
#Java(TM) SE Runtime Environment 18.9 (build 11+28)
Java HotSpot(TM) 64-Bit Server VM 18.9 (build 11+28, mixed mode)
```

## Custom Asset Discovery WebLogic

针对Weglogic自定义安装的检测方法(全盘文件检索60秒timeout),最后列出所有registry.xml路径

### 原始xml文件样例

#### version 10.x raw

```bash
<component name="WebLogic Server" Version"10.3.4.0" InstallDir="/app/wls11g/bea/wlserver_10.3">
```

#### version 12.x raw

```bash
<distribution status="installed" name="WebLogic Server for FMW" version="12.1.3.0.0">
```

### WebLogic脚本

```bash
cd /tmp && foo=`timeout 60s find / -not -path "/proc/*" -type f -size -10M  -maxdepth 8 -name "registry.xml" 2>/dev/null`; if [ $? -eq 124 ]; then echo "WebLogic not found (Timeout)"; else touch assetemp.log;  for bar in $foo; do grep  "WebLogic Server" $bar | awk -F '=' '{ print $4 }'| cut -c 2- | sed 's/..$//' >>assetemp.log; done; for bar in $foo; do grep -i 'component name="WebLogic Server" Version' $bar | awk -F '"' '{ print $4 }' >>assetemp.log; done; for ver in `uniq assetemp.log 2>/dev/null`; do echo "WebLogic Version: $ver"; done; echo $foo; fi; rm -f assetemp.log*
```

### WebLogic输出样例

```bash
WebLogic Version: 12.1.3.0.0_fake
WebLogic Version: 12.1.3.0.0
WebLogic Version: 12.2.1.0_fake
WebLogic Version: 10.3.4.0
/root/registry.xml /tmp/registry.xml /tmp/wlstest/registry.xml
```

## Custom Asset Discovery Tomcat

同时对自定义及标准安装Tomcat进行检测(全盘文件检索30秒timeout)

### Tomcat脚本

```bash
cd /tmp && foo='for bar in `timeout 30s find / -not -path "/proc/*" -type f -size -10M  -maxdepth 8 -name "version.sh" 2>/dev/null | grep tomcat`; do sh $bar; done'; bash -c "$foo" > assetemp.log 2>/dev/null; grep -i "Apache Tomcat" assetemp.log  | awk -F "/"  '{print $2}' >assetemp.log1; for ver in `sort assetemp.log1 2>/dev/null | uniq`; do echo "Tomcat Version: $ver"; done; rm -f assetemp.log*
```

### Tomcat输出样例

```bash
Tomcat Version: 7.0.76
Tomcat Version: 8.5.39
```

## Custom Asset Discovery Nginx

同时对自定义及标准安装Nginx进行检测(全盘文件检索30秒timeout)

### Nginx脚本

```bash
cd /tmp && foo='for bar in `timeout 30s find / -executable -type f -size -10M  -maxdepth 8 -name nginx 2>/dev/null`; do $bar -v 2>&1; done'; bash -c "$foo" >assetemp.log 2>/dev/null; grep -i "nginx version" assetemp.log  | awk -F "/"  '{print $2}' >assetemp.log1; for ver in `sort assetemp.log1 2>/dev/null | uniq`; do echo "Nginx Version: $ver"; done; rm -f assetemp.log*
```

### Nginx输出样例

`Nginx Version: 1.15.10`

## Custom Asset Discovery PHP

同时对自定义及标准安装php进行检测(全盘文件检索30秒timeout)

### PHP脚本

```bash
cd /tmp && foo='for bar in `timeout 30s find / -executable -type f -size -10M  -maxdepth 8 -name php 2>/dev/null`; do $bar -v 2>&1; done'; bash -c "$foo" >assetemp.log 2>/dev/null; grep -i "^PHP" assetemp.log  | awk '{print $2}' >assetemp.log1; for ver in `sort assetemp.log1 2>/dev/null | uniq`; do echo "PHP Version: $ver"; done; rm -f assetemp.log*
```

### PHP输出样例

`PHP Version: 7.0.33`

## Custom Asset Discovery Apache

一种比较简单的实现做法，先使用'which -a'找到所有httpd binary

### Apache脚本

```bash
for bar in `which -a httpd 2>/dev/null`; do $bar -v; done
```

### Apache输出样例

```bash
Server version: Apache/2.4.6 (CentOS)
Server built:   Nov  5 2018 01:47:09
```

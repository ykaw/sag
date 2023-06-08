# System Activity Grapher - インストール手順
# rootでの作業
最初に、ルート権限でSAGの実行に必要なソフトのインストールとアカウントの作成を行います。
## gitのインストール
gitは、SAGをGitHubから取得するために必要です。
```
# pkg_add git
quirks-6.121 signed 2023-06-01 07:54:26
quirks-6.121: ok
  :
  :
git-2.40.0: ok
The following new rcscripts were installed: /etc/rc.d/gitdaemon
See rcctl(8) for details.
New and changed readme(s):
	/usr/local/share/doc/pkg-readmes/git
#
```
## gnuplotのインストール
SAGは、グラフの描画をgnuplotを使って行っているため、gnuplotをインストールします。  
インストールを開始すると、どのパッケージを使うか訊かれるので「1: gnuplot-5.2.7p1」を選択します。  
gnuplot-5.2.7p1-no_x11は、PNGなどの画像ファイルを生成する機能を持っていません。
```
# pkg_add gnuplot
quirks-6.121 signed 2023-06-01 07:54:26
Ambiguous: choose package for gnuplot
a	0: <None>
	1: gnuplot-5.2.7p1
	2: gnuplot-5.2.7p1-no_x11
Your choice: 1
gnuplot-5.2.7p1:readline-7.0p0: ok
   :
   :
gnuplot-5.2.7p1: ok
Running tags: ok
New and changed readme(s):
	/usr/local/share/doc/pkg-readmes/glib2
#
```
## sagユーザの作成
SAGを実行するユーザ「sag」を作成します。
```
 adduser -silent
Enter username []: sag
Enter full name []: System Activity Grapher
Enter shell csh git-shell ksh nologin sh [ksh]:
uid [1000]:
Login group sag [sag]:
Login group is ``sag''. Invite sag into other groups: guest no
[no]:
Login class authpf bgpd daemon default pbuild staff unbound vmd xenodm
[default]:
Enter password []:
Enter password again []:

Name:	     sag
Password:    ****
Fullname:    System Activity Grapher
uid:	     1000
gid:	     1000 (sag)
groups:	     sag
Login Class: default
HOME:	     /home/sag
Shell:	     /bin/ksh
OK? (y/n) [y]: y
added user ``sag''
copy files from /etc/skel to /home/sag
add another user? (y/n) [y]: n
Goodbye!

```
 sagユーザでの作業
降の作業はsuコマンドを実行し、一時的にsagユーザになって行います。
```
su - sag

```
# SAGの取得と配置
GitHubから最新バージョンのSAGを取得します。
```
$ git clone https://github.com/ykaw/sag
Cloning into 'sag'...
remote: Enumerating objects: 515, done.
remote: Counting objects: 100% (92/92), done.
remote: Compressing objects: 100% (48/48), done.
remote:　Total　515:(delta(40),5reused 66 (delta 33), pack-reused 423
Receiving objects: 100% (515/515), 368.37 KiB | 784.00 KiB/s, done.
Resolving deltas: 100% (229/229), done.
$
```
取得したファイル群はsagというディレクトリに格納されているので、それをsagユーザのホームディレクトリに移動します。
```
$ mv sag/.git sag/* ~
$ rmdir sag
$ ls -l ~
total 22
-rw-r--r--  1 sag  sag  3304 Jun  3 01:39 README.en
-rw-r--r--  1 sag  sag  2687 Jun  3 01:39 README.eucjp
drwxr-xr-x  2 sag  sag   512 Jun  3 02:35 bin
drwxr-xr-x  3 sag  sag   512 Jun  3 01:41 conf
drwxr-xr-x  3 sag  sag   512 Jun  3 02:35 plot
drwxr-xr-x  2 sag  sag  1024 Jun  3 04:10 var
$ 
```
## gnuplotへのシンボリックリンクを作成
PATH環境変数の設定に関係なく実行できるよう、binディレクトリにgnuplotのシンボリックリンクを作成します。
```
$ ln -s /usr/local/bin/gnuplot ~/bin
$ ls -l ~/bin
total 24
-rwxr-xr-x  1 sag  sag   298 Jun  3 01:39 addgap
-rwxr-xr-x  1 sag  sag   721 Jun  3 01:39 fnrot
-rwxr-xr-x  1 sag  sag   860 Jun  3 01:39 gengraph
lrwxr-xr-x  1 sag  sag    22 Jun  3 01:40 gnuplot -> /usr/local/bin/gnuplot
-rwxr-xr-x  1 sag  sag   785 Jun  3 01:39 mkoldsum
-rwxr-xr-x  1 sag  sag   947 Jun  3 01:39 rotate
-rwxr-xr-x  1 sag  sag  1030 Jun  3 01:39 split_byday
-rw-r--r--  1 sag  sag   258 Jun  3 02:20 t0001
-rw-r--r--  1 sag  sag   255 Jun  3 01:39 t0005
-rw-r--r--  1 sag  sag   236 Jun  3 01:39 t0100
-rw-r--r--  1 sag  sag   104 Jun  3 01:39 t2400
-rwxr-xr-x  1 sag  sag   437 Jun  3 01:39 tick
$ 
```
## 設定ファイルの編集
### サンプルファイルをコピー
confディレクトリのexamplesディレクトリからファイルをコピーし、編集します。
```
$ cd ~/conf
$ ls -l
total 10
drwxr-xr-x  2 sag  sag  512 Jun  3 01:43 examples
$ cp examples/dfplot.gp examples/netcmd.sh examples/postgproc.sh examples/shconf.sh .
$ ls -l
total 10
-rw-r--r--  1 sag  sag  398 Jun  3 01:41 dfplot.gp
drwxr-xr-x  2 sag  sag  512 Jun  3 01:43 examples
-rw-r--r--  1 sag  sag  245 Jun  3 01:41 netcmd.sh
-rwxr-xr-x  1 sag  sag  326 Jun  3 01:44 postgproc.sh
-rw-r--r--  1 sag  sag  384 Jun  3 02:12 shconf.sh
$ 
```
### dfplot.gpの編集
dfplot.gpは、ディスク使用率の表示を行う際に必要なシステムのパーティション構成を設定するファイルです。  
dfコマンドの出力に合わせ、内容を編集します。

サンプルファイルは、河豚板をモード0で起動した場合のファイルシステムに合わせてあります。
```
$ df
Filesystem  512-blocks      Used     Avail Capacity  Mounted on
/dev/rd0a         3039      2088       951    69%    /
/dev/cd0a      2094988   2094988         0   100%    /sysmedia
/dev/vnd5a     2040700   2037920      2780   100%    /fuguita
mfs:69062      1494238    581876    837652    41%    /ram
$ vi dfplot.gp
```
編集内容
```
# definitions of disk partitions
#
# $Id: INSTALL-JA.md,v 1.1 2023/06/08 07:55:00 kaw Exp $
#
# This file will included from $SAGHOME/plot/gen0100df.gp
# Reconfigure following to fit to the disk layout.

plot "sumtmp-0100df" using 1:3 title "RDROOT", \      <--+  この部分をdfコマンドの
     "sumtmp-0100df" using 1:4 title "LIVEMEDIA", \      |  出力に合わせて編集
     "sumtmp-0100df" using 1:5 title "SYSTEM", \         | (1:3が一番最初に表示される
     "sumtmp-0100df" using 1:6 title "WRITABLE"       <--+  パーティション)
```
### netcmd.shの編集
測定対象としたいネットワークデバイスを指定します。
```
$ vi netcmd.sh
```
編集内容
```
# a command line to get i/f name, send/receive bytes
# then print them out
#
# this command will eval-ed by $SAGHOME/bin/t00
#
# $Id: INSTALL-JA.md,v 1.1 2023/06/08 07:55:00 kaw Exp $

netcmd='set $(netstat -I bce0 -b -n -i); echo $7 ${11} ${12}'
                         ~~~~ここを実際のインターフェース名に変更
```
### shconf.shの編集
shconf.shでは、測定項目、ファイルに保存する日数、測定項目それぞれのグラフへの描画日数を指定します。  
サンプルファイルの内容でよければ、編集する必要はありません。
```
$ vi shconf.sh
```
編集内容
```
#  shconf.sh  -  shell variable configuration for SAG
#
#  $Id: INSTALL-JA.md,v 1.1 2023/06/08 07:55:00 kaw Exp $

# categories to process data
#
targets='0001la 0001net 0005mem 0100df 0100time 0005timeofs'

# days to store data
#
rotate_max=64  <--ファイルに保存する日数

# days to display graph  <--グラフに描画する日数
#
     span_la=8
    span_net=8
    span_mem=8
     span_df=32
   span_time=32
span_timeofs=8
```
## グラフ描画関連のセットアップ
plotディレクトリでは、データの集計とグラフの描画指示を行っています。  
デフォルト設定から変えなければ、examplesディレクトリから必要ファイルをコピーするだけでOKです。
```
$ cd ~/plot
$ cp examples/common.gp examples/gen* .
$ ls -l
total 40
-rw-r--r--  1 sag  sag  1207 Jun  3 01:42 common.gp
drwxr-xr-x  2 sag  sag   512 Jun  3 01:39 examples
-rw-r--r--  1 sag  sag   259 Jun  3 01:42 gen0001la.gp
-rwxr-xr-x  1 sag  sag   882 Jun  3 01:42 gen0001la.pl
-rw-r--r--  1 sag  sag   356 Jun  3 01:42 gen0001net.gp
-rwxr-xr-x  1 sag  sag  1502 Jun  3 01:42 gen0001net.pl
-rw-r--r--  1 sag  sag   418 Jun  3 01:42 gen0005mem.gp
-rwxr-xr-x  1 sag  sag  1046 Jun  3 01:42 gen0005mem.pl
-rw-r--r--  1 sag  sag   422 Jun  3 01:42 gen0005timeofs.gp
-rwxr-xr-x  1 sag  sag  1536 Jun  3 01:42 gen0005timeofs.pl
-rw-r--r--  1 sag  sag   160 Jun  3 01:42 gen0100df.gp
-rwxr-xr-x  1 sag  sag   553 Jun  3 01:42 gen0100df.pl
-rw-r--r--  1 sag  sag   198 Jun  3 01:42 gen0100time.gp
-rwxr-xr-x  1 sag  sag   338 Jun  3 01:42 gen0100time.pl
$
```
gen*.plファイルは生ログから目的とする測定項目を集計し、出力するPerlスクリプトです。
gen*.gpファイルは、集計結果からgnuplotでグラフの画像ファイルを生成するための描画指示です。  
common.gpは、全ての測定項目で共通なgnuplotのグラフの描画設定が定義されています。

## ファイル置場の作成
測定結果の生ログやその集計ファイル、最終的な生成物であるグラフの画像ファイルを置くディレクトリを作成します。
```
$ mkdir ~/var
```
# rootでの作業
以降は、sagユーザから抜けて再度root権限で作業します。
```
$ exit
#
```
## システムファイルの設定
### rootのcrontabにSAG関連のエントリを追加します。
```
# cd ~sag/conf/examples/
# crontab -l > crontab.orig
# cat crontab.orig crontab-root | crontab -
```
### /etc/rc.localの編集
システムが起動した時のSAG関連の処理を/etc/rc.localに追加し、その一部を編集します。
```
# cat rc.local >> /etc/rc.local
# vi /etc /rc.local
```
編集内容
```
# for System Activity Grapher
# Add this to /etc/rc.local
#
# $Id: INSTALL-JA.md,v 1.1 2023/06/08 07:55:00 kaw Exp $

su -l sag -c 'PATH-TO-CMD/bin/addgap' # Rewrite to the real location.
              ~~~~~~~~~~~実際のパス(/home/sag)に書換え
# setups for ntp monitoring
#
touch /tmp/ntpctl.out
chown sag:sag /tmp/ntpctl.out
chmod 0640 /tmp/ntpctl.out
```
### sagユーザのcrontabを有効化します。
これ以降、SAGの測定が開始されます。
```
# crontab -u sag ~sag/conf/examples/crontab
```
## ウェブサーバ関連の設定
以下は、SAGが生成したグラフをウェブブラウザで閲覧するための設定です。  
グラフの画像ファイルを画像ビューアで直接見るなどの場合は必要ありません。

### postgproc.shの編集
postgproc.shは、グラフ画像ファイルが生成された後の処理を行い、サンプルファイルでは画像ファイルがウェブのコンテンツディレクトリへコピーされる処理がコメントアウトされています。  
ウェブ経由で画像を閲覧する場合は、postgroc.shを編集し、処理を有効化します。

編集はsagユーザ権限で行います。
```
# su - sag
$ vi ~/conf/postgproc.sh
```
編集内容
```
#!/bin/sh

# processes after generating graphs
# This script will be called by $SAGHOME/bin/t0100
#
# $Id: INSTALL-JA.md,v 1.1 2023/06/08 07:55:00 kaw Exp $

# To enable this,

# # Make next line commented.
# exit 0                       <--この行をコメント化する

# and follwing lines uncommented
#
# sample of post process
sleep 60                       <--この行以降をアンコメントする
cp $SAGHOME/var/*.png /var/www/htdocs/sag/.

$ exit
#
```

## ウェブ関連の設定
ウェブサーバ関連の設定です。
```
# mkdir /var/www/htdocs/sag
# cp index.html /var/www/htdocs/sag                                        
# chown -R sag:sag /var/www/htdocs/sag
```
httpd.confの編集
```
# vi /etc/httpd.conf
```
編集内容
```
 server "example.com" {
     listen on * port 80
 }
```
これはウェブサーバを稼働させるための最低限の設定です。ユーザ認証による閲覧制限やTLSによる通信を行いたい場合はhttpd.conf(5)などを参照して下さい。

ウェブサーバを起動します。
```
# rcctl enable httpd
# rcctl start httpd
```

# その他
## あとかたづけ
SAGのインストール後に、gitを使う用事がなければ、gitとその依存パッケージをアンインストールできます。
```
# pkg_delete git
git-2.40.0: ok
Read shared items: ok
--- -git-2.40.0 -------------------
You should also run /usr/sbin/userdel _gitdaemon
You should also run /usr/sbin/groupdel _gitdaemon
# pkg_delete -a  
ngtcp2-0.13.1:curl-8.1.1: ok
ngtcp2-0.13.1: ok
p5-Error-0.17029: ok
cvsps-2.1p2: ok
p5-Mail-Tools-2.21p0: ok
p5-Time-TimeDate-2.33: ok
nghttp3-0.9.0: ok
nghttp2-1.52.0: ok
Read shared items: ok
# 
```
## 動作の確認
- sagのcrontabエントリを有効化した後、varディレクトリに測定結果の生ログrl0001, rl0005, rl0100が生成されていることを確認します。

- 毎時50分にグラフの生成が行われるので、その後にグラフの画像ファイルが生成されていることを確認します。また、ウェブでの閲覧を設定した場合は、ウェブブラウザでも閲覧できることを確認します。

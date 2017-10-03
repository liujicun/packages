
在RHEL6.1上安装Oracle 11g R2




第一步，准备前置条件

    ./install_oracle_step1.sh



第二步，安装Oracle软件

    1. 图形界面安装（中文）

        ./install_oracle_step2.sh

    2. 图形界面安装（英文）

        ./install_oracle_step2.sh --en



第三步，安装后设置

    ./install_oracle_step3.sh



第四步，oracle服务控制

    /etc/init.d/oracle start|stop|status|restart


-------------------------------------------------------------------------------

说明：安装脚本内的中文注释采用UTF-8字符集，请在支持此字符集的语言环境中查看

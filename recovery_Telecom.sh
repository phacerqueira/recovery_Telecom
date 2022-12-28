#!/bin/bash

#DEFINIÇÃO E FORMATAÇÃO DO LOG

log="/var/log/recovery_Telecom.log"
dt=$(date +%Y-%m-%d__%H:%M:%S);

#CHECANDO DISTRO LINUX

SERVER_OS=`cat /etc/issue | grep Debian | awk '{print $1}'`

# MONITORAMENTO DE MEMORIA RAM

MAX_RAM=`free -m | grep "Mem" | awk '{print $2}'`
USO_RAM=`free -m | grep "Mem" | awk '{print $3}'`
PERCENT_RAM=$((100*$USO_RAM/$MAX_RAM))

# CHECANDO PID DO CALLCENTER

PID_CALLCENTER=`ps -A -o pid,cmd | egrep "java -jar" | egrep "callcenter.jar callcenter" | egrep -v egrep | awk '{print $1}' | wc -l`

# CHECANDO PID DO DISCADOR

PID_DISCADOR=`ps -A -o pid,cmd | egrep "java -jar" | egrep "callcenter.jar discador" | egrep -v egrep | awk '{print $1}'`

# CHECANDO PID DO CALLCENTER CONF

PID_CONF_CC=`ps -A -o pid,cmd | egrep "java -jar" | egrep "callcenter.jar conf" | egrep -v egrep | awk '{print $1}'`

echo "==============================================" >> $log
echo "Recovery Telecom - V3.1" >> $log
echo "==============================================" >> $log

# ANALISANDO PIDS DO ASTERISK E DO SERVIDOR WEB DE ACORDO COM O SISTEMA OPERACIONAL

if [ -z $SERVER_OS ]
    then
        echo "$dt - Sistema: CentOS" >> $log
        PID_ASTERISK=`ps -A -o pid,cmd | grep -w '/usr/sbin/asterisk -f -vvvg -c' | grep -v grep | awk '{print $1}' | wc -l` 
        echo "$dt - Análise de Servidor WEB ajustada para httpd" >> $log
        PID_WEBSRV=`ps -A -o "%p : %a"| grep "/usr/sbin/httpd" | grep -v grep | wc -l`
        echo "==============================================" >> $log
    else
        echo "$dt - Sistema: Debian" >> $log
        PID_ASTERISK=`ps -A -o pid,cmd | grep -w '/usr/sbin/asterisk' | grep -v grep | awk '{print $1}' | wc -l` 
        echo "$dt - Análise de Servidor WEB ajustada para Apache2" >> $log
        PID_WEBSRV=`ps -A -o "%p : %a" | grep "/usr/sbin/apache2" | grep -v grep | awk '{print $1}' | wc -l`
        echo "==============================================" >> $log
fi

##############################################################################################################

##CHECANDO ASTERISK PELA CONTAGEM DE PIDS

if [ $PID_ASTERISK == 0 ]
    then
        echo "$dt - Numero de PIDs do Asterisk == $PID_ASTERISK" >> $log
        echo "$dt - Asterisk PARADO..." >> $log
        /etc/init.d/asterisk stop
        /etc/init.d/asterisk start
        echo "$dt - Asterisk REINICIADO." >> $log
        echo "==============================================" >> $log
    elif [ $PID_ASTERISK -gt 1 ]
	then     
        echo "$dt - Numero de PIDs do Asterisk == $PID_ASTERISK" >> $log   	
	    echo "$dt - Asterisk COM MÚLTIPLOS PIDS" >> $log
        /etc/init.d/asterisk stop
        /etc/init.d/asterisk start
        echo "$dt - Asterisk REINICIADO." >> $log
        echo "==============================================" >> $log
    else
        echo "$dt - Asterisk OK - Nada a fazer..." >> $log
        echo "==============================================" >> $log
fi

##CHECANDO UTILIZACAO DE RAM


echo "$dt - Utilizacao de memoria RAM em $PERCENT_RAM%" >> $log

if [ $PERCENT_RAM -gt 90 ]
    then
    	echo "$dt - ALTO USO DE MEMÓRIA RAM - DROPANDO CACHES" >> $log
    	echo 3 > /proc/sys/vm/drop_caches
        echo "==============================================" >> $log
    else
    	echo "$dt - Uso de memoria OK - Nada a fazer" >> $log
        echo "==============================================" >> $log
fi

#CHECANDO CALLCENTER

if [ $PID_CALLCENTER = 0 ]
    then
        echo "$dt - Numero de PIDs do CallCenter == $PID_CALLCENTER" >> $log
        echo "$dt - Callcenter PARADO" >> $log
        /etc/init.d/callcenter restart
        echo "$dt - Callcenter REINICIADO." >> $log
        echo "==============================================" >> $log
        /etc/init.d/callcenter_conf restart
        echo "$dt - Callcenter_Conf REINICIADO." >> $log
        echo "==============================================" >> $log       
    elif [ $PID_CALLCENTER -gt 1 ]
    then
        echo "$dt - Numero de PIDs do CallCenter == $PID_CALLCENTER" >> $log
        echo "$dt - Callcenter DUPLICADO" >> $log
        /etc/init.d/callcenter restart
        echo "$dt - Callcenter REINICIADO." >> $log
        echo "==============================================" >> $log
        /etc/init.d/callcenter_conf restart
        echo "$dt - Callcenter_Conf REINICIADO." >> $log
        echo "==============================================" >> $log        
    else 
        echo "$dt - Callcenter OK - Nada a fazer" >> $log
        echo "==============================================" >> $log
fi

#CHECANDO DISCADOR

if [ $PID_DISCADOR = 0 ]
    then
        echo "$dt - Numero de PIDs do Discador == $PID_CALLCENTER" >> $log
        echo "$dt - Discador PARADO" >> $log
        /etc/init.d/callcenter restart
        echo "$dt - Callcenter REINICIADO." >> $log
        echo "==============================================" >> $log
        /etc/init.d/callcenter_conf restart
        echo "$dt - Callcenter_Conf REINICIADO." >> $log
        echo "==============================================" >> $log
    elif [ $PID_CALLCENTER -gt 1 ]
    then
        echo "$dt - Numero de PIDs do Discador == $PID_CALLCENTER" >> $log
        echo "$dt - Discador DUPLICADO" >> $log
        /etc/init.d/callcenter restart
        echo "$dt - Callcenter REINICIADO." >> $log
        echo "==============================================" >> $log
        /etc/init.d/callcenter restart
        echo "$dt - Callcenter_Conf REINICIADO." >> $log
        echo "==============================================" >> $log        
    else 
        echo "$dt - Discador OK - Nada a fazer" >> $log
        echo "==============================================" >> $log
fi

##CHECANDO CALLCENTER_CONF

if [ -z PID_CONF_CC ];
    then
        echo "$dt - Callcenter_Conf PARADO" >> $log
        /etc/init.d/callcenter restart
        echo "$dt - Callcenter REINICIADO." >> $log
        echo "==============================================" >> $log
        /etc/init.d/callcenter_conf restart
        echo "$dt - Callcenter_Conf REINICIADO." >> $log
        echo "==============================================" >> $log
    else
        echo "$dt - Callcenter_Conf OK - Nada a fazer..." >> $log
        echo "==============================================" >> $log
fi

##CHECANDO APACHE/HTTPD

if [ $PID_WEBSRV = 0 ];
        then
            echo "$dt - APACHE PARADO" >> $log
            if [ -z $SERVER_OS ]
                then
                    /etc/init.d/httpd restart
                    echo "$dt - HTTPD REINICIADO." >> $log
                    echo "==============================================" >> $log
                else
                    /etc/init.d/apache2 restart
                    echo "$dt - APACHE REINICIADO." >> $log
                    echo "==============================================" >> $log 
                fi
        else
            echo "$dt - Apache ok - Nenhuma ação realizada" >> $log
            echo "$dt - Quantidade de PIDS do Apache = $PID_WEBSRV" >> $log
            echo "==============================================" >> $log
fi


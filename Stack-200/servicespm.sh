#!/bin/bash
set -e ;

cp /etc/hosts ~/hosts.new ;
sed -i "/127.0.0.1/c\127.0.0.1 localhost localhost.localdomain `hostname`" ~/hosts.new ;
cp -f ~/hosts.new /etc/hosts ;

service sendmail start ;

if [ -d /opt/processmaker/ ];
then
    echo "ProccessMaker installed";
else
    if [[ -z "${PM_URL}" ]];
    then
        echo "ProccessMaker isn't installed";
        mkdir -p /opt/processmaker/workflow/public_html/ ;
        echo "ProccessMaker isn't installed" > /var/www/noindex/index.html;
    else
    ##### install processmaker #####
        cd /tmp/ && wget ${PM_URL} ;
        tar -C /opt -xzvf processmaker* ;
        
        cp /opt/processmaker/pmos.conf.example /etc/httpd/conf.d/pmos.conf ;
        sed -i 's@DocumentRoot /example/path/to/processmaker/workflow/public_html@DocumentRoot /opt/processmaker/workflow/public_html@' /etc/httpd/conf.d/pmos.conf ;
        sed -i 's@<Directory /example/path/to/processmaker/workflow/public_html>@<Directory /opt/processmaker/workflow/public_html>@' /etc/httpd/conf.d/pmos.conf ;

        cd /opt/processmaker/ ;
        chmod -R 770 shared workflow/public_html gulliver/js ;
        cd /opt/processmaker/workflow/engine/ ;
        chmod -R 770 config content/languages plugins xmlform js/labels ;
        chown -R apache:apache /opt/processmaker ;
        rm -rf /tmp/processmaker* ;      

        if [ -d /opt/processmaker/gulliver/thirdparty/html2ps_pdf/cache/ ];
        then
            chmod -R 770 /opt/processmaker/gulliver/thirdparty/html2ps_pdf/cache ;
        else
            chmod -R 770 /opt/processmaker/thirdparty/html2ps_pdf/cache ;
        fi
    fi
fi

echo "
       ░░░░░░░
    ░░░░░░░░░░░░░
   ░░░░       ░░░░     WELCOME TO PROCESSMAKER STACK 200 -> ( amazonlinux:2017.09 ; APACHE-2.4 ; PHP-5.5 )
  ░░░░  ░░░░░   ░░░
  ░░░  ░░░░░░░  ░░░░   - This stack of ProcessMaker use MySql 5.5
  ░░░  ░░░░░░   ░░░    - The following command run mysql56 in Docker:
   ░░  ░░     ░░░░     -> docker run --name pm-db55 -e MYSQL_ROOT_PASSWORD=PM-Testdb -p 3306:3306 -d mysql:5.5
    ░  ░░░░░░░░░       
       ░░░░░░░         For more information see https://www.processmaker.com
                                                http://wiki.processmaker.com/3.2/Supported_Stacks
	 " ; 
rm -f /usr/local/apache2/logs/httpd.pid ;

httpd -DFOREGROUND ;
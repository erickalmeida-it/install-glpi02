#!/bin/bash
# Descrição: GLPI INSTALL
# Criado por: Erick Almeida
# Data de Criacao: 26/01/2022
# Ultima Modificacao: 26/01/2022
# Compativél com o Ubuntu 18.04 (Homologado)

echo -e "\e[01;31m                    SCRIPT DE INSTALAÇÃO PARA O GLPI - INTERATIVO - UBUNTU SERVER 20.04     \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para iniciar...                        \e[00m"
read #pausa até que o ENTER seja pressionado

# ATUALIZAR REPOSITÓRIOS,PACOTES E A DISTRIBUIÇÃO DO SISTEMA OPERACIONAL

echo -e "\e[01;31m                  ATUALIZANDO PACOTES,REPOSITÓRIOS E A DISTRIBUIÇÃO DO SISTEMA OPERACIONAL   \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado

apt update -y
apt upgrade -y
apt dist-upgrade -y

# INSTALAR DE DEPENDENCIAS

echo -e "\e[01;31m                                          INSTALANDO DEPENDENCIAS                            \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado

apt install bash-completion chrony xz-utils libarchive-tools bzip2 unzip curl sendmail
apt install apache2 libapache2-mod-php php-soap php-cas 
apt install php-{apcu,curl,gd,imap,ldap,mysql,xmlrpc,xml,mbstring,bcmath,intl,zip,bz2}
apt install php-mail libphp-phpmailer 

# BAIXAR, EXTRAIR, MOVER E APAGAR DOWNLOAD DO GLPI 

echo -e "\e[01;31m                       BAIXAR, EXTRAIR, MOVER E APAGAR DOWNLOAD DO GLPI E PLUGINS            \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado

wget https://github.com/glpi-project/glpi/releases/download/9.5.6/glpi-9.5.6.tgz
tar -zxvf glpi-9.5.6.tgz
mv glpi /var/www/
rm -rf glpi-9.5.6.tgz
wget https://github.com/erickalmeida-it/downloads/raw/master/plugins-glpi.zip
unzip plugins-glpi.zip && rm -rf plugins-glpi.zip && mv * /var/www/glpi/plugins/

# AJUSTAR OS PERMISSIONAMENTOS DE ESCRITA 

echo -e "\e[01;31m                                AJUSTANDO OS PERMISSIONAMENTOS DE ESCRITA                    \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado

chown www-data:www-data /var/www/glpi -Rf
chmod 775 /var/www/glpi -Rf

# CRIAÇÃO DO BANCO DE DADOS

echo -e "\e[01;31m                                         CRIANDO DO BANCO DE DADOS                             \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                         \e[00m"
read #pausa até que o ENTER seja pressionado
echo -e "\e[01;31m                                     SIGA OS PASSOS NA SEGUINTE ORDEM:                         \e[00m"
echo -e "\e[01;31m                                             ENTER,N,Y,N,Y & Y                                 \e[00m"
echo -e "\e[01;31m                                           INFORMAÇÕES DO DB:                                  \e[00m"
echo -e "\e[01;31m                                            NOME DO DB: glpi                                   \e[00m"
echo -e "\e[01;31m                                            USUÁRIO DO DB: glpi                                \e[00m"
echo -e "\e[01;31m                                            SENHA DO DB: glpi                                  \e[00m"
echo -e "\e[01;31m  CASO NECESSÁRIO VOCÊ PODE ALTERAR AS LINHAS 66,67 E 68 PARA DIFINIR USUARIO E SENHA DE ACORDO COM SUA PREFERENCIA \e[00m"

mysql_secure_installation 
mysql -e "create database glpidb character set utf8"
mysql -e "create user 'glpi'@'localhost' identified by 'glpi'"
mysql -e "grant all privileges on glpidb.* to 'glpi'@'localhost' with grant option"
mysql -e "flush privileges"

# CRIAR VIRTALHOST E HABILITAR O ACESSO WEB

echo -e "\e[01;31m                               CRIANDO VIRTALHOST E HABILITANDO O ACESSO WEB                 \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado


echo "GLPI *:72
<VirtualHost *:72> 
  DocumentRoot /var/www/glpi
  #ServerName localhost
 <Directory /var/www/html/glpi>
  AllowOverride All
 </Directory>
 <Directory /var/www/html/glpi/config>
 Options -Indexes
  </Directory>
 <Directory /var/www/html/glpi/files> Options -Indexes
 </Directory>
</VirtualHost>" > /etc/apache2/sites-available/glpi.conf

sed -i '7i\\' /etc/apache2/ports.conf
sed -i '6s/$/ /' /etc/apache2/ports.conf
sed -i "6s/^./Listen 72/" /etc/apache2/ports.conf

a2ensite glpi
systemctl reload apache2


# AJUSTAR O APACHE

echo -e "\e[01;31m                                            AJUSTANDO O APACHE                               \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado

sed -i 's/memory_limit = 128M/memory_limit = 512M/g' /etc/php/7.4/apache2/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 600/g' /etc/php/7.4/apache2/php.ini
sed -i 's/session.use_strict_mode = 0/session.use_strict_mode = 0/g' /etc/php/7.2/apache2/php.ini
sed -i 's/session.use_trans_sid = 0/session.use_trans_sid = 0/g' /etc/php/7.4/apache2/php.ini
sed -i 's/session.auto_start = 0/session.auto_start = off/g' /etc/php/7.4/apache2/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 128M/g' /etc/php/7.4/apache2/php.ini
sed -i 's/file_uploads = On/file_uploads = On/g' /etc/php/7.4/apache2/php.ini

/etc/init.d/apache2 restart

# EFETUADO AJUSTE DE FIREWALL

echo -e "\e[01;31m                                            AJUSTANDO FIREWALL                               \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para continuar...                       \e[00m"
read #pausa até que o ENTER seja pressionado

systemctl enable ufw
ufw allow 22
ufw allow 80
ufw allow 443
ufw allow 72

echo -e "\e[01;31m                    NA INSTALAÇÃO ESTÁ INCLUSO OS PLUGINS ACTUAL-TIME E O MOD, HABILITE-OS           \e[00m"
echo -e "\e[01;31m             A INSTALAÇÃO SUCEDEU BEM, SEU SERVIDOR SERÁ REINICIADO E PODERÁS UTILIZAR O ERPNEXT     \e[00m"
echo -e "\e[01;31m                              EM SEU NAVEGADOR ACESSE http://IPDOSEUSERVIDOR:72                      \e[00m"
echo -e "\e[01;31m                                       Tecle <ENTER> para encerrar...                                \e[00m"
read #pausa até que o ENTER seja pressionado

reboot
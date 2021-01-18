#!/bin/bash
######################################################################
# Script developed by Javier Suarez to deploy Wordpress and Filebeat #
######################################################################
#
#Wordpress will be connected to wordDB mySQL Database
#

#I'm using main function as entry point for all the process
main() {

 #Updating repos and calling Wordpress function
 sudo apt-get update
 wordpress
}

#Wordpress function taking care of installation and configuration Wordpress process
wordpress() {

 #Installing Wordpress
 sudo apt install -y wordpress php libapache2-mod-php mysql-server php-mysql
 #Create a default site in Wordpress, I'm adding default INFO from wordconf text file
 sudo touch /etc/apache2/sites-available/wordpress.conf
 sudo bash -c 'cat /vagrant/wordconf >> /etc/apache2/sites-available/wordpress.conf'
 #Then I'm enabling this site and reloading apache2 config and service
 sudo a2ensite wordpress
 sudo service apache2 reload
 sudo a2enmod rewrite
 sudo systemctl restart apache2
 #Calling MySQL function to connect the database wordDB
 mysql
}

#MySQL function taking care of installation and configuration MySQL process
mysql() {

 #I need to create a DATABASE to configure Wordpress
 sudo mysql -u root -e "CREATE DATABASE IF NOT EXISTS wordDB;"
 sudo mysql -u root -e "CREATE USER javier IDENTIFIED BY 'javier00';"
 sudo mysql -u root -e "GRANT ALL ON wordDB.* TO javier;"
 sudo mysql -u root -e "FLUSH PRIVILEGES;"
 #Configure this MySQL with Wordpress, to do this I'm using mysqlconf file
 sudo bash -c 'cat /vagrant/mysqlconf >> /etc/wordpress/config-localhost.php'
 #I'm starting MySQL service
 sudo service mysql start
 #Calling Filebeat function which get the logs and send them to Logstash
 filebeat
}

#Filebeat function taking care of installation and configuration Filebeat process
filebeat() {

 #Filebeat will be used to send data to ELK stack, in this case to Logstash
 #So first it's to add repositories to install Filebeat
 curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.10.0-amd64.deb
 sudo dpkg -i filebeat-7.10.0-amd64.deb
 #Mandatory to comment Elasticsearch values and add Logstash values in yml file
 sudo sed -i '176 c\#output.elasticsearch:' /etc/filebeat/filebeat.yml
 sudo sed -i '178 c\#host: ["10.0.15.30:9200"]' /etc/filebeat/filebeat.yml
 sudo sed -i '189 c\output.logstash:' /etc/filebeat/filebeat.yml
 sudo sed -i '191 c\output.logstash.hosts: 192.168.1.3:5044' /etc/filebeat/filebeat.yml
 #Enable Filebeat modules needed for logstash
 sudo filebeat modules enable system
 sudo filebeat modules enable logstash
 #Enable the Filebeat service and in this case I'm setting to start it at boot
 sudo systemctl enable filebeat
 sudo service filebeat start
 #
 #This is a Filebeat trick! In case the script is running more than one time, Filebeat create one register per iteration.
 #DAMN! This could lead with several beats running in the same registry and it will cause to stop beat process
 #So with this I'm telling Filebeat to use this path to avoid default registry and executing it in background 
 #
 sudo filebeat -e --path.data "/var/lib/filebeat/6" &
}

# Entry point to start the bash script

main 


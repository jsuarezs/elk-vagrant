#!/bin/bash
#########################################################
# Script developed by Javier Suarez to deploy ELK stack #
#########################################################

# Cheking for JAVA installed in the system

dependency_check() {

 # Installing Java 8, at least 7 is required and 8 is stable. 
  sudo apt-get update
  sudo apt-get install -y openjdk-8-jdk
  # Deploying ELK stack after JAVA is already installed
  deploy_elk

}

#Deploy_elk is the function taking care of ELK stack installation and configuration
deploy_elk() {

  #ELK is compossed of Elasticsearch, Logstash and Kibana so I start with Elasticsearch
  elastic

}

#Elastic is the function taking care of Elasticsearch installation and configuration process
elastic() {

  #Elasricsearch repositories needed for Elasticsearch
  wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
  #Mandatory to enable HTTPS protocol to get the repositories
  sudo apt-get install apt-transport-https
  echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
  sudo apt-get update
  #Installing Elastic
  sudo apt-get install elasticsearch
  #In case of Elasticsearch it's necessary to add localhost as Elastic server and without cluster configuration (single-node)
  sudo sed -i '/192/ c network.host: localhost' /etc/elasticsearch/elasticsearch.yml
  sudo sed -i '/9200/ c http.port: 9200' /etc/elasticsearch/elasticsearch.yml
  sudo sed -i '$a discovery.type: single-node' /etc/elasticsearch/elasticsearch.yml
  #I'm setting  128m and 512m in the JVM options as recommended following documentation, this will avoid Java process to consume more than expected
  sudo sed -i '/-Xms512/ c -Xms128m' /etc/elasticsearch/jvm.options
  #Restarting and enabling at boot Elasticsearch
  sudo systemctl start elasticsearch.service 
  sudo systemctl enable elasticsearch.service
  #Calling Kibana function responsible to install and configure Kibana
  kibana
}

#Kibana is the function taking care of Kibana installation and configuration process
kibana() {

  #Updating repos and deploying Kibana
  sudo apt-get update
  sudo apt-get install kibana
  #Setting network parameters for Kibana in this host, port listening for Elastic and Kibana port
  sudo sed -i '2 c\server.port: 5601' /etc/kibana/kibana.yml
  sudo sed -i '7 c\server.host: 0.0.0.0' /etc/kibana/kibana.yml
  sudo sed -i '28 c\elasticsearch.hosts: http://localhost:9200' /etc/kibana/kibana.yml
  #Restarting and enabling at boot Kibana
  sudo systemctl start kibana
  sudo systemctl enable kibana
  #I'm allowing traffic in 5601 port for localhost in case firewall is enabled
  sudo ufw allow 5601/tcp
  #Calling Logstash function to install and configure Logstash
  logstash
}

#Logstash is the function taking care of Logstash installation and configuration
logstash() {

 #Installing Logstash
 sudo apt-get install logstash
 #Configuring logstash config.d file with logconf text file to allow 5400  input and outputs to Elasticsearch
 sudo touch /etc/logstash/conf.d/logstash-log.conf
 sudo bash -c 'cat /vagrant/logconf >> /etc/logstash/conf.d/logstash-log.conf'
 #Restarting and enabling at boot Logstash
 sudo service logstash start
 sudo systemctl enable logstash
 exit 0
}


# Entry point to call functions in order to deploy JAVA and ELK stack

dependency_check
deploy_elk

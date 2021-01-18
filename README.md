# Deploying ELK to get Wordpress metrics

**Author - Javier Suárez Sanz**

# Table of Contents
* [ELK Stack](#elk)
* [Wordpress](#app)

## Intention of this

**So, what is the ELK Stack?** 

"ELK" is the acronym for three open source projects: Elasticsearch, Logstash, and Kibana. Elasticsearch is a search and analytics engine. Logstash is a server‑side data processing pipeline that ingests data from multiple sources simultaneously, transforms it, and then sends it to a "stash" like Elasticsearch. Kibana lets users visualize data with charts and graphs in Elasticsearch.
The Elastic Stack is the next evolution of the ELK Stack.

**What is WordPress?**

WordPress is open source software you can use to create a beautiful website, blog, or app.

So the intention is to have Wordpress up and running and ELK stak to receive metrics from the site for analytics purposes.

----------

As requested we will deploy the following schema:

 **_app_ VM** (vagrant ssh _app_)

  1. Wordpress (over Apache) - Connected to wordDB MySQL.
  2. Filebeat - Responsible to send logs to Logstash.

**_elk_ VM** (vagrant ssh _elk_)

  1. Elasticsearch(logs BBDD)
  2. Logstash (Logs comingfromFilebeat)
  3. Kibana (Dashboards)


## <a name="elk"></a>ELK Stack

ELK stack is mounted in an Ubuntu Bionic64. VM called _elk_ with the following requirements:

- 3072m as enough memory to cover the completed ELK stack as following documentation Elasticsearch required high memory size.
https://www.elastic.co/guide/en/elasticsearch/reference/current/important-settings.html#heap-size-settings
- Private network called elk_network to communicate with _APP_ side.
- Forwarding Kibana guest port 5601 to host port 1234 to check GUI from Kibana (Figure 1 attached - right side).
- Private IP: 192.168.1.3

To check the site is up and running always go to the URL:
**http://localhost:1234**

When everything is running we can also check we're receiving from Filebeat data called Filebeat* as it's shown in figure 3, figure 4 and figure 5 follow by the date got it, in my case the last one was **filebeat-7.10.0-2020.11.24.**

### Configuration to have in mind

- JAVA as dependency to deploy ELK at least 8 version. It was found that could work with 7 but the recommended it's version 8.
https://www.elastic.co/guide/en/elasticsearch/reference/6.8/setup.html

- Configuration in _/etc/elasticsearch/elasticsearch.yml_ to allow communication in 9200 port in localhost. It's recommended to set _network.host_ parameter to 0.0.0.0 to allow connections from everywhere, in this case our local host.
- To avoid JAVA overhead it's important to change values in _/etc/elasticsearch/jvm.options_ to _Xms512_ and _Xms128_.

- Kibana is listening in 5601 port which has to be configured in _/etc/kibana/kibana.yml_ with the server itself, _localhost_.
- Set Firewall rules to allow TCP traffic in 5601 port in case firewall is enabled.

- Logstash is listening in 5400 port configured in _/etc/logastash/logstash-log.cong_ where it's set to send the output to Elasticsearch instance, in this case the server itself.

-----

## <a name="app"></a>Wordpress

Application part is mounted in an Ubuntu Bionic64 VM called _app_ with the following requirements:

- 1024m as memory to cover MySQL database and Apache2 configuration.
- Private network called elk_network to communicate with ELK stack.
- Forwarding guest port 80 to host port 7000 to install and see WordPress site under **localhost:7000/blog** URL (Figure 1 attached - left side).
- Private IP: 192.168.1.2

To check the site is up and running always go to my alias **/blog** using the URL:
**http://localhost:7000/blog**


### Configuration to have in mind

- WordPress needs Apache2 running behind, indeed this can be checked accesing **localhost:7000**. 
- Create a default site in _/etc/apache2/sites-available/wordpress.conf_ with the content of _wordconf_ txt file.
- This new site was enabled and Apache2 was reload with the new configuration.

- MySQL database called _wordDB_ was created and linked to Wordpress site using the content of _mysqlconf_ text file.

- Filebeat was installed to send logs from application to Logstash.
- In this case Elasticsearch section was commented in _/etc/filebeat/filebeat.yml_ and uncommented Logstash section to point _elk_ VM IP in 5044 port to allow communication throught it.

-----



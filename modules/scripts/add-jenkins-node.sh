
wget --no-check-certificate https://jenkins.galitu.site/jnlpJars/jenkins-cli.jar
wget --no-check-certificate https://jenkins.galitu.site/jnlpJars/jenkins-cli.jar


java -jar jenkins-cli.jar -noCertificateCheck  -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s https://jenkins.galitu.site install-plugin build-monitor-plugin:1.13+build.202205071934

java -jar jenkins-cli.jar -noCertificateCheck  -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s https://jenkins.galitu.site install-plugin blueocean:1.25.3

java -jar jenkins-cli.jar -noCertificateCheck  -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s https://jenkins.galitu.site install-plugin slack:608.v19e3b_44b_b_9ff

java -jar jenkins-cli.jar -noCertificateCheck  -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s https://jenkins.galitu.site install-plugin matrix-auth:3.1.2

java -jar jenkins-cli.jar -noCertificateCheck  -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s https://jenkins.galitu.site who-am-i -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c

address of cli
https://jenkins.galitu.site/cli


java -jar jenkins-cli.jar -noCertificateCheck  -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s https://jenkins.galitu.site/ -webSocket get-node JenkinsAgent_1

cat jenkins_agent_connect.xml | java -jar jenkins-cli.jar -noCertificateCheck  -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s https://jenkins.galitu.site/ -webSocket create-node JenkinsAgent_2

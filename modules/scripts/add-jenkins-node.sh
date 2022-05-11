
wget http://lb-jenkins-mprj-kandula-1740977339.eu-central-1.elb.amazonaws.com/jnlpJars/jenkins-cli.jar
wget http://LB-jenkins-mprj-Kandula-1740977339.eu-central-1.elb.amazonaws.com/jnlpJars/jenkins-cli.jar


java -jar jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s http://lb-jenkins-mprj-kandula-1740977339.eu-central-1.elb.amazonaws.com install-plugin build-monitor-plugin:1.13+build.202205071934

java -jar jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s http://lb-jenkins-mprj-kandula-1740977339.eu-central-1.elb.amazonaws.com install-plugin blueocean:1.25.3

java -jar jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s http://lb-jenkins-mprj-kandula-1740977339.eu-central-1.elb.amazonaws.com install-plugin slack:608.v19e3b_44b_b_9ff

java -jar jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s http://lb-jenkins-mprj-kandula-1740977339.eu-central-1.elb.amazonaws.com install-plugin matrix-auth:3.1.2

java -jar jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s http://lb-jenkins-mprj-kandula-1740977339.eu-central-1.elb.amazonaws.com who-am-i -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c

address of cli
http://LB-jenkins-mprj-Kandula-1740977339.eu-central-1.elb.amazonaws.com/cli


java -jar jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s http://lb-jenkins-mprj-kandula-1740977339.eu-central-1.elb.amazonaws.com/ -webSocket get-node JenkinsAgent_1

cat jenkins_agent_connect.xml | java -jar jenkins-cli.jar -auth galitu:113addc54d29cfb5a38bcbb402c9aaf46c -s http://lb-jenkins-mprj-kandula-1740977339.eu-central-1.elb.amazonaws.com/ -webSocket create-node JenkinsAgent_2

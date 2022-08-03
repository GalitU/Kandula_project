
<b> From here what will be done... </b><br>
Remark: All process of creating, updating, assigning, installation, fine tuning will be done from my PC by:
  - Terraform, including remote provisioning via bastion host and user data template files
      - There will be separated modules for specific purpose in separeated directories
      - For each purpose exist specific bash script and its state will be saved into separated directory inside S3 bucket
      - There are possibility execute each script any time, it will take all relevant VPC elements by data resource of Terraform
      - There exist specific modules for different purposes and lot of outputs for allow usage in different automated scripts
      - There will be assigned many different tags to all environment elements for allow automatic configration
  - Python scripts
  - Bash scripts
  - Ansible playbooks
  - Jenkins CLI
  - GitHub webhooks
  - Jenkins jobs
  - Jinga2 templates files
  - All servers (except Kube worker nodes) will Ubuntu 20.04 OS
  - Kube worker nodes will be on Linux mashine


 AWS ENVIRONMENT
1. Will be created S3 for keep all TF states. All TF states are saved in to relevant directories, depends of purpose
   - Name of S3 bucket is s3-fprj-kandula-bucket
   - This bucket is private
   - Inside structure:
    - bastion/
    - consul/
    - jenkins/
    - keys/
    - kube/
    - vpc/
    - elk/
    - kube_kandula_app/

 2. Will be created VPC and all relevant NAT, IG, subnets, route tables
   - Will be created 2 public subnets for:
      - 1 Bastion(Jump) host
      - 1 Load balancer for Consul servers
      - 1 Load balancer for Jenkins server
      - 1 Load balancer for ELK server
   - Will be created 6 private subnets according the purpose (3 groups, each group has 2 subnets one by one per AZ
      - private subnets for 3 consul servers
      - private subnets for Master servers:
           1 Jenkins Server
           2 Jenkins Slaves/Agents/Nodes... never mind how call them :)
           1 ELK server
      - 2 private subnets for 4 Kubernetes worker nodes

 3. Will be created private keys for all servers according to purpose - one per subnet pair.
   - There will be updated automatically permissions of PEM files according SSH requirenment to 400
   - After all keys are created they are copied dynamically into ~/.ssh/SSH_KEYS_FOR_Amazon directory
     where ~/.ssh/config file of my PC takes the configuration and connect to servers via SSH
   - Bastion servers key
   - Consul servers key
   - Master servers key for Jenkins server and slave
   - Web servers key - now it not in use, due to creating EKS nodes with out key

 4. Creating Bastion host in public subnet.
   - New public IP address of bastion host will be taken automatically from terraform output and used inside update of ~/.ssh/config file, see below...
   - There will be only 1 server in entire environment which will be exposed to public internet.
   - It will be possible to connect by SSH only from 1 external IP address (my PC).
     It is limitted by Security group and ingress rules.
   - I can update my IP address depends where I am placed in the world by execute ./TERRAFORM/SCRIPT/Only_bastion_crt.sh any time
   - After the Bastion host will be created there will start dynamic updating of its external IP into ~/.ssh/config file
   - It will be done by python script ./TERRAFORM_FULL/SCRIPTS/update_config_ssh_file.py via TF
   - There will be creates new role for bastion host with Describe policies
   - There will be istalled consul service on Bastion host, including heatlh checker of it by port 22, see 'Consul' below

 5. Creating kubernetes cluster
  - There will be created :
      - EKS cluster with name kandula-prj-kube
      - It will be placed on private subnets for Kubernetes worker, see 2.2.-
      - There will be created :
          - 4 Kandula_worker_m medium workers in 2 nodegroups          
      - There will be assigned next Security Groups
          - Consul SG
          - SSH SG
          - Node exporter SG
      - Will be created relevant roles
      - After entire cluster environment will be created its info will be updated automatically in local PC at ~/.kube/config file
      - Next steps will start Kandula deployment application based kubernetes cluster
          - There prepared separated github repo for Kandula deployment process at https://github.com/GalitU/Kandula_deployment
                - Each commit there with updated new docker image version will cause to Jenkins trigger for start deploy
                - For first creating environment it will be executed automatically as part TF action
          - All releant credential keys for Kandula application (AWS_KEY... will be encripted by base64
                 algorithm and inserted to kubernetes secret file which will be started by kubectl tool
                 - This yaml file will be local on my PC and not commited to GIT.
                 - For Jenkins Kandula start execution this yaml file will be created dynamically based on Jenkins secret environment text
                 - Created secret file will be deleted immidiatelly after it will be started by kubectl tool
          - Elements which will be started:
              - Secret file started by kubectl
              - Kandula deployment for 2 replicas based on last docker image version
              - Ingress (ALB) for Kandula with DNS record https://kandula.galitu.site/login
              - Prometheus via HELM and TF
              - Ingress (ALB) for Prometheus with DNS record https://prometheus.galitu.site/graph
              - Grafana via HELM and TF
              - Ingress (ALB) for Gatafana with DNS resord https://grafana.galitu.site/?orgId=1
              - 4 worker nodes which are adssigned to kube cluster
      Remark: script which create kube env. will be executed twice due to lot of Terraform bugs  and network performance issues

 6. Creating CI environment based on Jenkins server technology
  - There will be created :
     - Jenkins server
          - It was installed once by TF and configured for start manually
          - It was saved in private AMI snapshot from which Jenkins server is created by Terraform any time after that
          - Jenkins server itself placed on private subnet with purpose 'Master'
          - Jenkins server uses Key_Master_Kandula_FPrj.pem key
          - Jenkins server has Security Groups for acceess for:
              - SSH
              - port 8080
              - consul ports
          - There were added Discovery and all EKS policies to Jenkins server
          - To this node will be assigned label Master and it not should execute any jobs
          - There added public Load Balancer to Jenkins server for access to its UI with exposed port 80
          - Jenkins server is connected to GitHub for receive webhooks as trigger for start automatic CI/Cd process
          - There will be istalled consul service on Jenkins server, including heatlh checker of it by port 22, see 'Consul' below
     - 2 Jenkins slaves
          - It was installed by TF
          - Jenkins slaves placed on private subnet with purpose 'Master'
          - Jenkins slaves uses Key_Master_Kandula_FPrj.pem key
          - Jenkins slaves has Security Groups for acceess for:
              - SSH
              - consul ports
          - There were added Discovery and all EKS policies to Jenkins slaves
          - To all slave nodes will be assigned next labels
              - Slave
              - Ansible
              - docker
              - kubectl
          - Jenkins slaves are executors for all CI/CD processes
              - Git actions: (checkout, commit, push, web-hooks)
              - Docker actions: (create image, push image, pull image)
              - Tool and scripts (Bash, Python, kubectl)
          - After createing new environment or changing number of slaves automatically start process
            of connecting relevant Jenkins slaves to Jenkins server and update new SSH creadentials between Jenkins server and slaves
            by ./TERRAFORM_FULL/JENKINS/add_jenkins_node.py
              - This is python script which use jenkins CLI and terraform output for connect relevant new IPs to jenkins server
              - In case when added new Slave script will update exist and add new
              - In case when deleted some Slaves script will delete unrelevant connection
              - All connection will start only after the Jenkins up and running, srcipt just for that and poll it
          - There will be istalled consul service on Jenkins slaves, including heatlh checker of it by port 22, see 'Consul' below

 7. Creating Consul servers and install relevant applications and relevant configuration of all environmet environment based on Jenkins server technology
  - There will be created :
      - 3 Consul servers
          - It was installed once by TF and configured after starting by Ansible playbook via SSH forwarding of Bastion host
          - Consul servers itself placed on private subnet with purpose 'Consul'
          - Consul server uses Key_Consul_Kandula_FPrj.pem
          - Consul server has Security Groups for acceess for:
              - SSH
              - port 8301
              - port 8300
              - port 8600
              - port 8500
      - There will be create Load balancer for allow public access to consul UI, all 3 consul servers will attached to him
      - There will installation of consul service on all consul servers and server
      - There will installation of consul agents on
          - Jenkins server
          - 2 Jenkins slavesserver
          - Bastion host

 8. At finish of installation the script will inform about all public relevant IPs like in next example<br>
=========================================================================<br>
CONSUL UI = [https://consul.galitu.site]<br>
JENKINS UI = [https://jenkins.galitu.site]<br>
KANDULA started at [https://kandula.galitu.site/]<br>
GRAFANA = [https://grafana.galitu.site/]<br>
PROMETHEUS UI = [https://prometheus.galitu.site/graph]<br>
=========================================================================<br>
====> All servers and services started OK<br>
=================================================<br>
 ====>>>>BUILD ENTIRE ENVIRONMENT FINISHED WITH SUCCESS<br>

 TOOLS and methodologies
1. <b>Git</b>
 - There exist next relevant repo for implement Kandula project
      - https://github.com/GalitU/Kandula_code
          - It contains all Kandula application code based on python
          - It contain Jenkinsfile which will be trigger to CI Kandula process
          - Commit to this repo will be done by developer and trigger Jenkins job https://jenkins.galitu.site/Start_Build_Docker_Kandula/
      - https://github.com/GalitU/Kandula_deployment
          - It contains all Kandula deployment manifests and relevant Jenkinsfile
          - It contain Jenkinsfile will start Kandula CD process by Jenkins job https://jenkins.galitu.site/job/Start_Deployment_Kandula/
          - Commit to this repo will be done by Jenkins job https://jenkins.galitu.site/job/Start_Build_Docker_Kandula/
      - https://github.com/GalitU/Kandula_project
          - It contains IaC which create AWS environment and which we start now
      - https://github.com/GalitU/Ansible_for_jenkins
          - It contains all ansible playbooks which will be executed by Jenkins jobs
            - Ansible_Consul_Install https://jenkins.galitu.site/job/Ansible_Consul_Install/
            - Ansible_filebeat_Install https://jenkins.galitu.site/job/Ansible_filebeat_Install/
            - Ansible_NodeExporter_Install https://jenkins.galitu.site/job/Ansible_NodeExporter_Install/
            

 2. Jenkins
  - There exist next relevant Jenkins jobs for execute all CI/CD processes
      - https://jenkins.galitu.site
          - This is multi-pipeline job
          - It based on Jenkisfile
          - It triggered by commit to Git repo https://github.com/GalitU/Kandula_code
          - List of stages
              - Clone from Git repo https://github.com/GalitU/Kandula_code
              - Docker build and Tag with number of version as build number
              - Push docker to private registry
              - Clean docker image from disk of Jenkins slave
              - Get Kandula pod manifests from https://github.com/GalitU/Kandula_deployment
              - Update manifest version number in deployment yaml file
              - Commit and push manifests to Git https://github.com/GalitU/Kandula_deployment
              - Inform Slack channel for process results
      - https://jenkins.galitu.site/job/Start_Deployment_Kandula/
          - This is multi-pipeline job
          - It triggered by commit to Git repo https://github.com/GalitU/Kandula_deployment
          - It based on Jenkisfile
          - List of stages
              - Get Kandula pod manifests from https://github.com/GalitU/Kandula_deployment
              - Update Kandula secrets
              - Update eks cluster configuration according cluster info
              - Validate Kandula current status
              - Start Kandula deployment with new version
              - Validate of starting of Kandula
              - Inform Slack channel for process results
      - https://jenkins.galitu.site/job/Start_manual_Kandula_deployment/
          - This is multi-pipeline job
          - It based on Jenkisfile
          - It manual execution job
          - List of stages
              - Get Kandula pod manifests from https://github.com/GalitU/Kandula_deployment
              - Update Kandula secrets
              - Update eks cluster configuration according cluster info
              - Validate Kandula current status
              - Start Kandula deployment with new version
              - Validate of starting of Kandula
              - Inform Slack channel for process results
      - https://jenkins.galitu.site/job/Stop_Kandula/
          - It manual execution job
          - which stops all kubernetes software elements (deployments, services, secret)

 3. Consul
  - Consul will monitor all relevant environment elements (nodes and services)
  - It installed by Ansible from TF process
  - On all Consul servers are installed service of server
  - On all other servers installed service of agent

 4. SSH configuration of my PC
   - Confiration of file was prepared once manually according the corelation of subnet purpose and Key
   - Update of file occured automatically any time when created/changed bastion host by ./TERRAFORM_FULL/SCRIPTS/update_config_ssh_file.py script

 5. Secrets
   - There are few secrets which relevant to this project
   - Private keys for access via SSH created and saved on my PC, there is only 1 key which are exported to Jenkins Server
     for access to Jenkins slaved and this is done by update credentials via Jenkins CLI
   - Access of Ansible done via bastian host to all relevant machine from my PC
   - Jenkins slaves need have access to AWS, so it was done by remote provision with local vars file of terraform and it not committed to GIT
   - AWS credentials for Kandula were saved on Jenkins server as environment variables and them inserted into kuberentes secret file with encripted base64
     algorithm, file is deleted imeediatelly after execution

 6. Logs
   - There exist log of full 'one click' build process
   - There exist log of full 'one click' destroy process
   - There exist notification of CI/CD jobs process to Slack channel
   - Kandula createds logs

 7. Kandula application - last but not least
   - It python based application which implements simple actions on AWS instances as:
      - Describe full list of instances and info of each instance
      - Show simple halth status
      - Start instance
      - Stop instance
      - Terminate instance
   - There prepared CLI tool https://github.com/GalitU/Kandula_project/tree/Final_Project/Kandula_code/app/cli/kandulacli.py for manage instances of Kandula
     
         -----
         Usage: kandulacli.py [OPTIONS] COMMAND [ARGS]...

         Options:
           --help  Show this message and exit.

         Commands:
           get_instance
           get_instances
           start_instance
           stop_instance
           terminate_instance

         ------
         Usage: kandulacli.py get_instances [OPTIONS]

         Options:
           -d, --debug          Add more debug info.
           -u, --url TEXT       Web address of site. Example :
                                https://kandula.galitu.sites
           --user TEXT          User name with which Kandula application is started
           -p, --password TEXT  Password with which Kandula application is started
           --help               Show this message and exit.

         

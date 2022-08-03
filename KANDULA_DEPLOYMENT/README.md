This directory will relevant for deployment all EKS application of Kubernetes.<br>
Deployment of this application will be executed by Jenkins jobs:
- https://jenkins.galitu.site/job/Start_Deployment_Kandula/ which will be triggered by commit to https://github.com/GalitU/Kandula_project/blob/Final_Project/KANDULA_DEPLOYMENT/Jenkinsfile
- https://jenkins.galitu.site/job/Start_manual_Kandula_deployment/ which will be executed manually and deploy last version

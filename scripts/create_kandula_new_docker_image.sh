##### cd /mnt/c/Data/OpsSchool/Codding/KANDULA_Virtual_env
##### docker build -t opsschool/kandula:3.0.0 .
##### docker run -it -e FLASK_ENV=development -e AWS_ACCESS_KEY_ID=AKIAXLA67BTZOCTFXIN5 -e AWS_SECRET_ACCESS_KEY=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 -e AWS_DEFAULT_REGION=eu-central-1 --name kandula-app --rm -p 5000:5000 opsschool/kandula:3.0.0
##### docker login --username galitu
##### docker tag 312dbeb2edc1 galitu/galitu-ops:kandula-mid-prj
##### docker images
##### docker push galitu/galitu-ops:kandula-mid-prj

######## Execution on remote server's docker
###### sudo docker run -it -e FLASK_ENV=development -e AWS_ACCESS_KEY_ID=AKIAXLA67BTZOCTFXIN5 -e AWS_SECRET_ACCESS_KEY=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 -e AWS_DEFAULT_REGION=eu-central-1 --name kandula-app --rm -p 5000:5000 galitu/galitu-ops:kandula-mid-prj


echo "open file and see the instaructions"

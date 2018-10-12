#!/usr/bin/env bash

echo "deploy site"
site_url="http://rotlis-esp.s3-website-ap-southeast-2.amazonaws.com"



#SAML2AWS_USERNAME=robert.sayfullin@gmail.com SAML2AWS_PASSWORD=$(getPass) ./saml2aws login -a AWS-NonProd -r arn:aws:iam::932185777718:role/assurance-developer-role

#unset SAML2AWS_PASSWORD
#export AWS_PROFILE=saml


#aws s3 cp ./static_site/ s3://rotlis-esp/ --recursive --profile
aws s3 cp ./static_site/ s3://rotlis-esp/ --recursive --profile rotlis
aws s3 cp ./modules/ s3://rotlis-esp/firmware/sonoff/ --recursive --profile rotlis
aws s3 cp ./firmware_sonoff/ s3://rotlis-esp/firmware/sonoff/ --recursive --profile rotlis
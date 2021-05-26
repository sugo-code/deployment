sudo yum -y install ruby

wget https://aws-codedeploy-eu-west-1.s3.eu-west-1.amazonaws.com/latest/install

chmod +x ./install
sudo ./install auto

sudo sed -i 's/""/"ec2-user"/g' /etc/init.d/codedeploy-agent
sudo sed -i 's/#User=codedeploy/User=ec2-user/g' /usr/lib/systemd/system/codedeploy-agent.service

sudo chown ec2-user:ec2-user -R /opt/codedeploy-agent/
sudo chown ec2-user:ec2-user -R /var/log/aws/ 

sudo systemctl daemon-reload
sudo systemctl start codedeploy-agent
sudo systemctl enable codedeploy-agent

sudo rm install

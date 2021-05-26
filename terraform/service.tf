# Machine used to initialize databases parameters db and auth db with sample data

resource "aws_instance" "service_machine" {
  ami = data.aws_ami.amazon_linux_2.id
  instance_type = aws_launch_template.docker.instance_type

  vpc_security_group_ids = [
    aws_security_group.main.id,
    aws_security_group.ssh.id
  ]
  subnet_id = aws_subnet.public.id

  key_name = var.ssh_key_name 
  tags = {
    Name = "${var.prefix}-service-machine"
  }

  user_data = base64encode(<<EOF
    #!/bin/bash

    cd /home/ec2-user

    cat > auth-roles.json <<EOL
    ${file("auth-roles.json")}
EOL

    cat > auth-users.json <<EOL
      ${file("auth-users.json")}
EOL

    cat > parameters-tables.sql <<EOL
      ${file("parameters-tables.sql")}
EOL

    cat > parameters-data.sql <<EOL
      ${file("parameters-data.sql")}
EOL

    wget https://downloads.mongodb.com/compass/mongodb-mongosh-0.13.2.el7.x86_64.rpm
    sudo yum -y install mongodb-mongosh-0.13.2.el7.x86_64.rpm
    sudo rm mongodb-mongosh-0.13.2.el7.x86_64.rpm
    
    sudo amazon-linux-extras install postgresql11

    aws docdb wait db-instance-available --db-instance-identifier ${aws_docdb_cluster_instance.auth_db.0.identifier}
    mongosh ${local.mongodb_url} --eval 'db.roles.insertMany(${file("auth-roles.json")})' > auth-roles.log 2>&1
    mongosh ${local.mongodb_url} --eval 'db.users.insertMany(${file("auth-users.json")})' > auth-users.log 2>&1

    aws rds wait db-instance-available --db-instance-identifier ${aws_db_instance.parameters_db.identifier}
    tr -d '\n' < parameters-tables.sql | psql ${local.postgresql_url} > parameters-tables.log 2>&1
    tr -d '\n' < parameters-data.sql | psql ${local.postgresql_url} > parameters-data.log 2>&1

    sudo shutdown -h now
    EOF
  )
}

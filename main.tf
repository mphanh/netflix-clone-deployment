terraform {
    required_providers {
        aws = "hashicorp/aws"
        version = "~> 4.0"
    }
}

provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "jenkins-server" {
    ami = "ami-0a0e5d9c7acc336f1" #ubuntu 22.04
    instance_type = "t2.large"
    key_name = "wave-cafe-prod-nvir"
    security_groups" = [aws_security_group.jenkins_sg.name]
    user_data = data.template.jenkins_server.rendered
}

resource "aws_instance" "prometheus_server" {
    ami = "ami-0a0e5d9c7acc336f1"
    instance_type = "t2.large"
    key_name = "wave-cafe-prod-nvir"
    security_groups" = [aws_security_group.prometheus_sg.name]
    user_data = data.template.prometheus_server.rendered
}

resource "aws_instance" "k8s_master" {
    ami = "ami-0a0e5d9c7acc336f1"
    instance_type = "t2.large"
    key_name = "wave-cafe-prod-nvir"
    security_groups" = [aws_security_group.k8s_sg.name]
    user_data = data.template.k8s_master.rendered
}

resource "aws_instance" "k8s_worker" {
    ami = "ami-0a0e5d9c7acc336f1"
    instance_type = "t2.large"
    key_name = "wave-cafe-prod-nvir"
    security_groups" = [aws_security_group.k8s_sg.name]
    user_data = data.template.k8s_worker.rendered
}

resource "aws_security_group" "jenkins_sg" {
    name = "jenkins-sg"

    # Ingress rule to allow all traffic from within the same security group
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"  # -1 means all protocols
        self        = true  # This allows traffic from instances using the same SG
    }
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [0.0.0.0/0]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [0.0.0.0/0]
    }

    #jenkins
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = [0.0.0.0/0]
    }

    #sonarqube
    ingress {
        from_port = 9000
        to_port = 9000
        protocol = "tcp"
        cidr_blocks = [0.0.0.0/0]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [0.0.0.0/0]
    }
}

resource "aws_security_group" "prometheus_sg" {
    name = "prometheus-sg"

    # Ingress rule to allow all traffic from within the same security group
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"  # -1 means all protocols
        self        = true  # This allows traffic from instances using the same SG
    }
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [0.0.0.0/0]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [0.0.0.0/0]
    }

    #prometheus
    ingress {
        from_port = 9090
        to_port = 9090
        protocol = "tcp"
        cidr_blocks = [0.0.0.0/0]
    }

    #node exporter
    ingress {
        from_port = 9100
        to_port = 9100
        protocol = "tcp"
        cidr_blocks = [0.0.0.0/0]
    }

    #grafana
    ingress {
        from_port = 3000
        to_port = 3000
        protocol = "tcp"
        cidr_blocks = [0.0.0.0/0]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [0.0.0.0/0]
    }
}

resource "aws_security_group" "k8s_sg" {
    name = "k8s-sg"

    # Ingress rule to allow all traffic from within the same security group
    ingress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"  # -1 means all protocols
        self        = true  # This allows traffic from instances using the same SG
    }
    
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [0.0.0.0/0]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = [0.0.0.0/0]
    }

    #node exporter
    ingress {
        from_port = 9100
        to_port = 9100
        protocol = "tcp"
        cidr_blocks = [0.0.0.0/0]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = [0.0.0.0/0]
    }
}

data "template" "jenkins_server" {
    template = file("jenkins_server.sh")
}

data "template" "prometheus_server" {
    template = file("prometheus_server.sh")
}

data "template" "k8s_master" {
    template = file("k8s_master.sh")
}

data "template" "k8s_worker" {
    template = file("k8s_master.sh")
}
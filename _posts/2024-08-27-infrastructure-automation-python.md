---
title: Infrastructure Automation with Python - From Scripts to Enterprise Solutions
date: 2024-08-27 11:00:00 +0800
categories: [Automation, Python]
tags: [python, automation, infrastructure, ansible, terraform, DevOps]
pin: false
---

# Infrastructure Automation with Python: Scaling Beyond Manual Processes

In today's fast-paced IT environment, manual infrastructure management is not just inefficient—it's a security risk. Python has emerged as the go-to language for infrastructure automation, offering powerful libraries and frameworks that transform how we manage systems at scale.

## Why Python for Infrastructure Automation?

### Key Advantages 🚀
- **Readable Syntax**: Easy to write, review, and maintain
- **Rich Ecosystem**: Extensive libraries for every infrastructure need
- **Cross-Platform**: Works seamlessly across Windows, Linux, and macOS
- **Strong Community**: Massive support and continuous development
- **Integration-Friendly**: APIs, REST services, and third-party tools

## Essential Python Libraries for Infrastructure

### 1. Network Automation

#### Netmiko - Multi-vendor Network Device Automation
```python
from netmiko import ConnectHandler

# Device configuration
cisco_device = {
    'device_type': 'cisco_ios',
    'host': '192.168.1.1',
    'username': 'admin',
    'password': 'secure_password',
    'secret': 'enable_password'
}

# Connect and execute commands
with ConnectHandler(**cisco_device) as net_connect:
    # Send configuration commands
    config_commands = [
        'interface GigabitEthernet0/1',
        'description Automated by Python',
        'ip address 10.1.1.1 255.255.255.0',
        'no shutdown'
    ]
    output = net_connect.send_config_set(config_commands)
    print(output)
    
    # Save configuration
    net_connect.save_config()
```

#### NAPALM - Network Automation and Programmability
```python
from napalm import get_network_driver

# Multi-vendor approach
driver = get_network_driver('ios')
device = driver('192.168.1.1', 'admin', 'password')

device.open()

# Get device facts
facts = device.get_facts()
interfaces = device.get_interfaces()

# Configuration deployment
device.load_merge_candidate(filename='config.txt')
diffs = device.compare_config()

if diffs:
    print("Configuration changes:")
    print(diffs)
    device.commit_config()

device.close()
```

### 2. System Administration

#### Paramiko - SSH Client for Remote Execution
```python
import paramiko
import time

class SSHManager:
    def __init__(self, hostname, username, password, port=22):
        self.hostname = hostname
        self.username = username
        self.password = password
        self.port = port
        self.client = None
    
    def connect(self):
        try:
            self.client = paramiko.SSHClient()
            self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.client.connect(
                hostname=self.hostname,
                port=self.port,
                username=self.username,
                password=self.password,
                timeout=10
            )
            return True
        except Exception as e:
            print(f"Connection failed: {e}")
            return False
    
    def execute_command(self, command):
        if self.client:
            stdin, stdout, stderr = self.client.exec_command(command)
            return stdout.read().decode(), stderr.read().decode()
        return None, "No connection established"
    
    def close(self):
        if self.client:
            self.client.close()

# Usage example
ssh = SSHManager('192.168.1.100', 'admin', 'password')
if ssh.connect():
    output, error = ssh.execute_command('df -h')
    print(f"Disk usage:\n{output}")
    ssh.close()
```

#### Fabric - High-level SSH Command Execution
```python
from fabric import Connection, Group
from invoke import task

# Single server operations
def deploy_application():
    with Connection('production-server.com') as conn:
        # Update system packages
        conn.sudo('apt update && apt upgrade -y')
        
        # Deploy application
        conn.put('app.tar.gz', '/tmp/')
        conn.run('cd /opt/myapp && tar -xzf /tmp/app.tar.gz')
        
        # Restart services
        conn.sudo('systemctl restart myapp')
        conn.sudo('systemctl restart nginx')

# Multiple server operations
def update_web_servers():
    web_servers = Group('web1.example.com', 'web2.example.com', 'web3.example.com')
    
    for conn in web_servers:
        # Graceful shutdown
        conn.run('sudo systemctl stop nginx')
        
        # Update configuration
        conn.put('nginx.conf', '/etc/nginx/nginx.conf')
        
        # Restart service
        conn.run('sudo systemctl start nginx')
        
        print(f"Updated {conn.host}")
```

### 3. Cloud Infrastructure Management

#### Boto3 - AWS SDK for Python
```python
import boto3
import json

class AWSManager:
    def __init__(self, region='us-east-1'):
        self.ec2 = boto3.client('ec2', region_name=region)
        self.s3 = boto3.client('s3', region_name=region)
        
    def create_security_group(self, group_name, description, vpc_id):
        try:
            response = self.ec2.create_security_group(
                GroupName=group_name,
                Description=description,
                VpcId=vpc_id
            )
            
            sg_id = response['GroupId']
            
            # Add inbound rules
            self.ec2.authorize_security_group_ingress(
                GroupId=sg_id,
                IpPermissions=[
                    {
                        'IpProtocol': 'tcp',
                        'FromPort': 22,
                        'ToPort': 22,
                        'IpRanges': [{'CidrIp': '0.0.0.0/0'}]
                    },
                    {
                        'IpProtocol': 'tcp',
                        'FromPort': 80,
                        'ToPort': 80,
                        'IpRanges': [{'CidrIp': '0.0.0.0/0'}]
                    }
                ]
            )
            
            return sg_id
        except Exception as e:
            print(f"Error creating security group: {e}")
            return None
    
    def launch_instance(self, ami_id, instance_type, key_name, security_group_id):
        try:
            response = self.ec2.run_instances(
                ImageId=ami_id,
                MinCount=1,
                MaxCount=1,
                InstanceType=instance_type,
                KeyName=key_name,
                SecurityGroupIds=[security_group_id],
                UserData='''#!/bin/bash
                yum update -y
                yum install -y httpd
                systemctl start httpd
                systemctl enable httpd
                '''
            )
            
            instance_id = response['Instances'][0]['InstanceId']
            return instance_id
        except Exception as e:
            print(f"Error launching instance: {e}")
            return None

# Usage
aws = AWSManager()
sg_id = aws.create_security_group('web-sg', 'Web server security group', 'vpc-12345678')
instance_id = aws.launch_instance('ami-0abcdef1234567890', 't2.micro', 'my-key', sg_id)
```

## Advanced Automation Frameworks

### 1. Ansible Integration with Python

```python
import ansible_runner
import yaml

def run_ansible_playbook(playbook_path, inventory_path, extra_vars=None):
    """Execute Ansible playbook from Python"""
    
    runner_result = ansible_runner.run(
        playbook=playbook_path,
        inventory=inventory_path,
        extravars=extra_vars or {},
        quiet=False
    )
    
    print(f"Status: {runner_result.status}")
    print(f"Return Code: {runner_result.rc}")
    
    # Process results
    for event in runner_result.events:
        if event['event'] == 'runner_on_failed':
            print(f"Task failed: {event['event_data']['task']}")
        elif event['event'] == 'runner_on_ok':
            print(f"Task succeeded: {event['event_data']['task']}")

# Dynamic inventory creation
def create_dynamic_inventory():
    inventory = {
        'webservers': {
            'hosts': ['web1.example.com', 'web2.example.com'],
            'vars': {
                'ansible_user': 'deploy',
                'nginx_port': 80
            }
        },
        'databases': {
            'hosts': ['db1.example.com'],
            'vars': {
                'mysql_root_password': 'secure_password'
            }
        }
    }
    
    with open('dynamic_inventory.yml', 'w') as f:
        yaml.dump(inventory, f, default_flow_style=False)
    
    return 'dynamic_inventory.yml'

# Usage
inventory_file = create_dynamic_inventory()
run_ansible_playbook('site.yml', inventory_file, {'env': 'production'})
```

### 2. Terraform Integration

```python
import subprocess
import json
import os

class TerraformManager:
    def __init__(self, working_dir):
        self.working_dir = working_dir
        os.chdir(working_dir)
    
    def init(self):
        """Initialize Terraform"""
        result = subprocess.run(['terraform', 'init'], 
                              capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    
    def plan(self, var_file=None):
        """Create Terraform plan"""
        cmd = ['terraform', 'plan', '-out=tfplan']
        if var_file:
            cmd.extend(['-var-file', var_file])
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    
    def apply(self, plan_file='tfplan'):
        """Apply Terraform plan"""
        result = subprocess.run(['terraform', 'apply', '-auto-approve', plan_file],
                              capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr
    
    def output(self):
        """Get Terraform outputs"""
        result = subprocess.run(['terraform', 'output', '-json'],
                              capture_output=True, text=True)
        if result.returncode == 0:
            return json.loads(result.stdout)
        return {}
    
    def destroy(self, var_file=None):
        """Destroy infrastructure"""
        cmd = ['terraform', 'destroy', '-auto-approve']
        if var_file:
            cmd.extend(['-var-file', var_file])
        
        result = subprocess.run(cmd, capture_output=True, text=True)
        return result.returncode == 0, result.stdout, result.stderr

# Infrastructure deployment pipeline
def deploy_infrastructure(environment):
    tf = TerraformManager(f'./terraform/{environment}')
    
    print("Initializing Terraform...")
    success, stdout, stderr = tf.init()
    if not success:
        print(f"Init failed: {stderr}")
        return
    
    print("Creating plan...")
    success, stdout, stderr = tf.plan(f'{environment}.tfvars')
    if not success:
        print(f"Planning failed: {stderr}")
        return
    
    print("Applying changes...")
    success, stdout, stderr = tf.apply()
    if success:
        outputs = tf.output()
        print("Infrastructure deployed successfully!")
        print(f"Outputs: {json.dumps(outputs, indent=2)}")
    else:
        print(f"Apply failed: {stderr}")

# Usage
deploy_infrastructure('staging')
```

## Monitoring and Logging Automation

### System Metrics Collection

```python
import psutil
import time
import json
import requests
from datetime import datetime

class SystemMonitor:
    def __init__(self, webhook_url=None):
        self.webhook_url = webhook_url
    
    def get_system_metrics(self):
        """Collect comprehensive system metrics"""
        return {
            'timestamp': datetime.now().isoformat(),
            'cpu': {
                'percent': psutil.cpu_percent(interval=1),
                'cores': psutil.cpu_count(),
                'load_avg': psutil.getloadavg()
            },
            'memory': {
                'percent': psutil.virtual_memory().percent,
                'available_gb': psutil.virtual_memory().available / (1024**3),
                'total_gb': psutil.virtual_memory().total / (1024**3)
            },
            'disk': {
                'percent': psutil.disk_usage('/').percent,
                'free_gb': psutil.disk_usage('/').free / (1024**3),
                'total_gb': psutil.disk_usage('/').total / (1024**3)
            },
            'network': {
                'bytes_sent': psutil.net_io_counters().bytes_sent,
                'bytes_recv': psutil.net_io_counters().bytes_recv
            }
        }
    
    def check_alerts(self, metrics):
        """Check for alert conditions"""
        alerts = []
        
        if metrics['cpu']['percent'] > 80:
            alerts.append(f"High CPU usage: {metrics['cpu']['percent']}%")
        
        if metrics['memory']['percent'] > 85:
            alerts.append(f"High memory usage: {metrics['memory']['percent']}%")
        
        if metrics['disk']['percent'] > 90:
            alerts.append(f"Low disk space: {metrics['disk']['percent']}% used")
        
        return alerts
    
    def send_alert(self, alerts):
        """Send alerts via webhook"""
        if alerts and self.webhook_url:
            payload = {
                'text': f"System Alert: {', '.join(alerts)}",
                'timestamp': datetime.now().isoformat()
            }
            requests.post(self.webhook_url, json=payload)
    
    def monitor_loop(self, interval=60):
        """Continuous monitoring loop"""
        while True:
            metrics = self.get_system_metrics()
            alerts = self.check_alerts(metrics)
            
            if alerts:
                print(f"ALERTS: {alerts}")
                self.send_alert(alerts)
            
            # Log metrics (could send to time-series database)
            print(f"System status: CPU {metrics['cpu']['percent']}%, "
                  f"Memory {metrics['memory']['percent']}%, "
                  f"Disk {metrics['disk']['percent']}%")
            
            time.sleep(interval)

# Usage
monitor = SystemMonitor('https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK')
monitor.monitor_loop(300)  # Check every 5 minutes
```

## Security Automation

### Vulnerability Scanning Integration

```python
import nmap
import json
from datetime import datetime

class SecurityScanner:
    def __init__(self):
        self.nm = nmap.PortScanner()
    
    def scan_network(self, network_range, scan_type='-sS'):
        """Perform network vulnerability scan"""
        print(f"Scanning {network_range}...")
        
        self.nm.scan(network_range, arguments=f'{scan_type} -O -A')
        
        results = {
            'scan_time': datetime.now().isoformat(),
            'network': network_range,
            'hosts': {}
        }
        
        for host in self.nm.all_hosts():
            host_info = {
                'state': self.nm[host].state(),
                'protocols': {},
                'os_detection': self.nm[host].get('osmatch', [])
            }
            
            for protocol in self.nm[host].all_protocols():
                ports = self.nm[host][protocol].keys()
                host_info['protocols'][protocol] = {}
                
                for port in ports:
                    port_info = self.nm[host][protocol][port]
                    host_info['protocols'][protocol][port] = {
                        'state': port_info['state'],
                        'name': port_info['name'],
                        'product': port_info.get('product', ''),
                        'version': port_info.get('version', ''),
                        'extrainfo': port_info.get('extrainfo', '')
                    }
            
            results['hosts'][host] = host_info
        
        return results
    
    def analyze_vulnerabilities(self, scan_results):
        """Analyze scan results for potential vulnerabilities"""
        vulnerabilities = []
        
        for host, info in scan_results['hosts'].items():
            for protocol in info['protocols']:
                for port, details in info['protocols'][protocol].items():
                    # Check for common vulnerable services
                    if details['name'] in ['ssh', 'telnet', 'ftp', 'http']:
                        if details['state'] == 'open':
                            vuln = {
                                'host': host,
                                'port': port,
                                'service': details['name'],
                                'risk': self.assess_risk(details),
                                'recommendation': self.get_recommendation(details)
                            }
                            vulnerabilities.append(vuln)
        
        return vulnerabilities
    
    def assess_risk(self, service_details):
        """Assess risk level of exposed service"""
        high_risk_services = ['telnet', 'ftp', 'rsh']
        medium_risk_services = ['ssh', 'http']
        
        service = service_details['name']
        
        if service in high_risk_services:
            return 'HIGH'
        elif service in medium_risk_services:
            return 'MEDIUM'
        else:
            return 'LOW'
    
    def get_recommendation(self, service_details):
        """Get security recommendation"""
        recommendations = {
            'telnet': 'Replace with SSH for encrypted communication',
            'ftp': 'Use SFTP or FTPS instead of plain FTP',
            'http': 'Implement HTTPS with proper SSL/TLS configuration',
            'ssh': 'Ensure strong authentication and disable root login'
        }
        
        return recommendations.get(service_details['name'], 
                                 'Review service configuration and access controls')

# Usage
scanner = SecurityScanner()
results = scanner.scan_network('192.168.1.0/24')
vulnerabilities = scanner.analyze_vulnerabilities(results)

print(f"Found {len(vulnerabilities)} potential vulnerabilities:")
for vuln in vulnerabilities:
    print(f"- {vuln['host']}:{vuln['port']} ({vuln['service']}) - {vuln['risk']} risk")
    print(f"  Recommendation: {vuln['recommendation']}")
```

## Best Practices for Infrastructure Automation

### 1. Error Handling and Logging
```python
import logging
from functools import wraps

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('automation.log'),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

def error_handler(func):
    """Decorator for consistent error handling"""
    @wraps(func)
    def wrapper(*args, **kwargs):
        try:
            result = func(*args, **kwargs)
            logger.info(f"Successfully executed {func.__name__}")
            return result
        except Exception as e:
            logger.error(f"Error in {func.__name__}: {str(e)}")
            raise
    return wrapper

@error_handler
def critical_infrastructure_task():
    # Your automation code here
    pass
```

### 2. Configuration Management
```python
import configparser
import os
from pathlib import Path

class ConfigManager:
    def __init__(self, config_file='config.ini'):
        self.config = configparser.ConfigParser()
        self.config_file = Path(config_file)
        self.load_config()
    
    def load_config(self):
        """Load configuration from file and environment"""
        if self.config_file.exists():
            self.config.read(self.config_file)
        
        # Override with environment variables
        for section in self.config.sections():
            for key in self.config[section]:
                env_var = f"{section}_{key}".upper()
                if env_var in os.environ:
                    self.config[section][key] = os.environ[env_var]
    
    def get(self, section, key, fallback=None):
        """Get configuration value with fallback"""
        return self.config.get(section, key, fallback=fallback)
```

### 3. Testing Infrastructure Code
```python
import unittest
from unittest.mock import patch, MagicMock

class TestInfrastructureAutomation(unittest.TestCase):
    
    @patch('subprocess.run')
    def test_terraform_init(self, mock_run):
        """Test Terraform initialization"""
        mock_run.return_value.returncode = 0
        mock_run.return_value.stdout = "Terraform initialized successfully"
        
        tf = TerraformManager('./test')
        success, stdout, stderr = tf.init()
        
        self.assertTrue(success)
        mock_run.assert_called_once_with(['terraform', 'init'], 
                                       capture_output=True, text=True)
    
    @patch('paramiko.SSHClient')
    def test_ssh_connection(self, mock_ssh):
        """Test SSH connection functionality"""
        mock_client = MagicMock()
        mock_ssh.return_value = mock_client
        
        ssh = SSHManager('testhost', 'user', 'pass')
        result = ssh.connect()
        
        self.assertTrue(result)
        mock_client.connect.assert_called_once()

if __name__ == '__main__':
    unittest.main()
```

## Conclusion

Python's versatility makes it the perfect choice for infrastructure automation. From simple scripts to complex orchestration platforms, Python provides the tools needed to:

1. **Automate repetitive tasks** - Reduce human error and increase efficiency
2. **Scale operations** - Manage hundreds or thousands of systems
3. **Integrate systems** - Connect disparate tools and platforms
4. **Monitor continuously** - Proactive system health monitoring
5. **Respond dynamically** - Automated incident response and remediation

The key to successful infrastructure automation is starting small, testing thoroughly, and gradually expanding your automation coverage. Remember: automate the boring stuff, so you can focus on the strategic challenges.

---

*What infrastructure challenges are you looking to automate? Share your automation success stories and challenges in the comments!*
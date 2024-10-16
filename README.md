# AWS Cost Optimization Framework

## Table of Contents

1. [Introduction](#introduction)
2. [Project Structure](#project-structure)
3. [Compute Optimization](#1-compute-optimization)
   - 1.1 [Right-Sizing Instances](#11-right-sizing-instances)
   - 1.2 [Utilize Spot Instances](#12-utilize-spot-instances)
   - 1.3 [Implement Auto Scaling](#13-implement-auto-scaling)
   - 1.4 [Use Reserved Instances and Savings Plans](#14-use-reserved-instances-and-savings-plans)
4. [Networking Optimization](#2-networking-optimization)
   - 2.1 [Optimize Data Transfer Costs](#21-optimize-data-transfer-costs)
   - 2.2 [Leverage Content Delivery Networks (CDNs)](#22-leverage-content-delivery-networks-cdns)
   - 2.3 [Optimize Load Balancers](#23-optimize-load-balancers)
5. [Storage Optimization](#3-storage-optimization)
   - 3.1 [Implement Lifecycle Policies](#31-implement-lifecycle-policies)
   - 3.2 [Delete Unused Data](#32-delete-unused-data)
   - 3.3 [Optimize EBS Volumes](#33-optimize-ebs-volumes)
   - 3.4 [Use Storage Classes Effectively](#34-use-storage-classes-effectively)
6. [Tracking Progress with Metrics](#4-tracking-progress-with-metrics)
7. [Reporting and Documentation](#5-reporting-and-documentation)
8. [Automation Recommendations and Scripts](#6-automation-recommendations-and-scripts)
   - 6.1 [Infrastructure as Code (IaC)](#61-infrastructure-as-code-iac)
   - 6.2 [Automated Instance Scheduling](#62-automated-instance-scheduling)
   - 6.3 [Resource Cleanup Automation](#63-resource-cleanup-automation)
9. [Continuous Improvement Process](#7-continuous-improvement-process)
10. [Conclusion](#8-conclusion)
11. [Next Steps](#9-next-steps)
12. [Appendix: Automated Scripts](#10-appendix-automated-scripts)

---

## Introduction

This framework is designed to help organizations optimize their AWS costs systematically. By implementing the strategies outlined in this document and utilizing the provided automated scripts, you can achieve significant cost savings while maintaining optimal performance and scalability.

---

## Project Structure

```
aws-cost-optimization/
├── README.md
├── scripts/
│   ├── compute/
│   │   ├── right_sizing.sh
│   │   ├── spot_instances_config.json
│   │   ├── auto_scaling_setup.sh
│   │   └── reserved_instances_recommendation.sh
│   ├── networking/
│   │   ├── create_vpc_endpoints.sh
│   │   └── cloudfront_distribution.json
│   ├── storage/
│   │   ├── lifecycle_policy.json
│   │   ├── cleanup_ebs_volumes.py
│   │   ├── ebs_recommendations.sh
│   │   └── s3_tiering_config.json
│   └── automation/
│       ├── stop_instances.py
│       ├── cleanup_snapshots.py
│       └── stop_rds_instances.py
```

- **README.md**: This markdown file containing the comprehensive framework.
- **scripts/**: Directory containing all the automated scripts organized by category.

---

## 1. Compute Optimization

### 1.1 Right-Sizing Instances

#### Action Plan

- **Analyze** current instance utilization using monitoring tools.
- **Identify** underutilized instances with low CPU and memory usage.
- **Resize** instances to better match workload requirements.

#### Metrics

- **CPU Utilization**: Target 60-70% average usage.
- **Memory Utilization**: Ensure memory allocation aligns with application needs.
- **Cost Savings**: Calculate savings from downsizing instances.

#### Automated Script

**File:** `scripts/compute/right_sizing.sh`

```bash
#!/bin/bash
# Script: right_sizing.sh
# Description: Retrieve EC2 instance right-sizing recommendations.

# Get recommendations for EC2 instances
aws compute-optimizer get-ec2-instance-recommendations \
    --query 'instanceRecommendations[*].{InstanceId:instanceId, CurrentType:currentInstanceType, RecommendedType:recommendationOptions[0].instanceType}' \
    --output table
```

---

### 1.2 Utilize Spot Instances

#### Action Plan

- **Identify** workloads suitable for Spot Instances (e.g., batch processing, stateless services).
- **Implement** Spot Instances with appropriate interruption handling.

#### Metrics

- **Cost Savings Percentage**: Compare Spot Instance costs to On-Demand pricing.
- **Interruption Rate**: Monitor frequency to ensure application reliability.

#### Automated Script

**File:** `scripts/compute/spot_instances_config.json`

```json
{
  "AutoScalingGroupName": "my-spot-asg",
  "MixedInstancesPolicy": {
    "InstancesDistribution": {
      "OnDemandPercentageAboveBaseCapacity": 0,
      "SpotAllocationStrategy": "lowest-price",
      "SpotInstancePools": 2
    },
    "LaunchTemplate": {
      "LaunchTemplateSpecification": {
        "LaunchTemplateId": "lt-0abcd1234efgh5678",
        "Version": "$Latest"
      }
    }
  },
  "MinSize": 1,
  "MaxSize": 10,
  "DesiredCapacity": 5
}
```

**Deployment Script:** `scripts/compute/auto_scaling_setup.sh`

```bash
#!/bin/bash
# Script: auto_scaling_setup.sh
# Description: Create an Auto Scaling group with Spot Instances.

aws autoscaling create-auto-scaling-group \
    --cli-input-json file://scripts/compute/spot_instances_config.json
```

---

### 1.3 Implement Auto Scaling

#### Action Plan

- **Set up** Auto Scaling groups based on demand metrics.
- **Define** scaling policies for scaling in and out.

#### Metrics

- **Resource Utilization**: Monitor to prevent over-provisioning.
- **Scaling Events**: Track frequency to optimize policies.

#### Automated Script

**Deployment Script:** `scripts/compute/auto_scaling_setup.sh` (Continued)

```bash
#!/bin/bash
# Script: auto_scaling_setup.sh
# Description: Create an Auto Scaling group with scaling policies.

# Create scaling policy
aws autoscaling put-scaling-policy \
    --auto-scaling-group-name my-spot-asg \
    --policy-name cpu-scale-out \
    --policy-type TargetTrackingScaling \
    --target-tracking-configuration file://scripts/compute/scale_out_config.json
```

**Scaling Policy Configuration:** `scripts/compute/scale_out_config.json`

```json
{
  "PredefinedMetricSpecification": {
    "PredefinedMetricType": "ASGAverageCPUUtilization"
  },
  "TargetValue": 70.0
}
```

---

### 1.4 Use Reserved Instances and Savings Plans

#### Action Plan

- **Analyze** long-term usage patterns.
- **Purchase** Reserved Instances or Savings Plans accordingly.

#### Metrics

- **Reserved Instance Coverage**: Aim for high coverage on steady-state workloads.
- **Cost Savings**: Monitor savings compared to On-Demand pricing.

#### Automated Script

**File:** `scripts/compute/reserved_instances_recommendation.sh`

```bash
#!/bin/bash
# Script: reserved_instances_recommendation.sh
# Description: Retrieve Reserved Instance purchase recommendations.

aws ce get-reservation-purchase-recommendation \
    --service "Amazon Elastic Compute Cloud - Compute" \
    --term-in-years ONE_YEAR \
    --payment-option NO_UPFRONT \
    --lookback-period-in-days SEVEN_DAYS \
    --output table
```

---

## 2. Networking Optimization

### 2.1 Optimize Data Transfer Costs

#### Action Plan

- **Analyze** data transfer patterns between regions and services.
- **Reduce** cross-region data transfers.
- **Implement** VPC Endpoints and AWS PrivateLink.

#### Metrics

- **Data Transfer Volume**: Monitor inter-region and internet data transfer.
- **Cost per GB Transferred**: Identify expensive transfer routes.

#### Automated Script

**File:** `scripts/networking/create_vpc_endpoints.sh`

```bash
#!/bin/bash
# Script: create_vpc_endpoints.sh
# Description: Create VPC Endpoints for S3 and DynamoDB in all VPCs.

# Replace with your AWS region
REGION="us-east-1"

# List VPC IDs
VPC_IDS=$(aws ec2 describe-vpcs --query 'Vpcs[].VpcId' --output text)

# For each VPC, create endpoints for S3 and DynamoDB
for VPC_ID in $VPC_IDS; do
  aws ec2 create-vpc-endpoint --vpc-id $VPC_ID --service-name com.amazonaws.$REGION.s3 --vpc-endpoint-type Gateway
  aws ec2 create-vpc-endpoint --vpc-id $VPC_ID --service-name com.amazonaws.$REGION.dynamodb --vpc-endpoint-type Gateway
  echo "Created VPC Endpoints for VPC: $VPC_ID"
done
```

---

### 2.2 Leverage Content Delivery Networks (CDNs)

#### Action Plan

- **Implement** Amazon CloudFront to cache content closer to users.
- **Configure** cache behaviors and TTLs appropriately.

#### Metrics

- **Cache Hit Ratio**: Aim for a high percentage.
- **Latency Metrics**: Monitor user experience improvements.

#### Automated Script

**Configuration File:** `scripts/networking/cloudfront_distribution.json`

```json
{
  "CallerReference": "unique-string-2023-01-01",
  "Origins": {
    "Quantity": 1,
    "Items": [
      {
        "Id": "S3-my-bucket",
        "DomainName": "mybucket.s3.amazonaws.com",
        "OriginPath": "",
        "S3OriginConfig": {
          "OriginAccessIdentity": ""
        }
      }
    ]
  },
  "DefaultCacheBehavior": {
    "TargetOriginId": "S3-my-bucket",
    "ViewerProtocolPolicy": "redirect-to-https",
    "AllowedMethods": {
      "Quantity": 2,
      "Items": ["GET", "HEAD"]
    },
    "ForwardedValues": {
      "QueryString": false,
      "Cookies": {
        "Forward": "none"
      }
    },
    "MinTTL": 0,
    "DefaultTTL": 86400,
    "MaxTTL": 31536000
  },
  "Enabled": true
}
```

**Deployment Command:**

```bash
aws cloudfront create-distribution --distribution-config file://scripts/networking/cloudfront_distribution.json
```

---

### 2.3 Optimize Load Balancers

#### Action Plan

- **Review** load balancer usage and performance.
- **Consolidate** or remove underutilized load balancers.
- **Choose** the appropriate load balancer type (ALB, NLB, or Gateway LB).

#### Metrics

- **Active Connection Count**: Identify low-traffic load balancers.
- **Throughput Metrics**: Ensure load balancers are efficiently utilized.

#### Automated Script

**Command:**

```bash
#!/bin/bash
# Script: analyze_load_balancers.sh
# Description: Analyze load balancer utilization.

# List all load balancers
LOAD_BALANCERS=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[].LoadBalancerArn' --output text)

# Get CloudWatch metrics for each load balancer
for ARN in $LOAD_BALANCERS; do
  LB_NAME=$(echo $ARN | awk -F/ '{print $NF}')
  aws cloudwatch get-metric-statistics \
    --namespace AWS/ApplicationELB \
    --metric-name ActiveConnectionCount \
    --dimensions Name=LoadBalancer,Value=$LB_NAME \
    --statistics Average \
    --start-time $(date -u -d '7 days ago' +%Y-%m-%dT%H:%M:%SZ) \
    --end-time $(date -u +%Y-%m-%dT%H:%M:%SZ) \
    --period 3600 \
    --output table
done
```

---

## 3. Storage Optimization

### 3.1 Implement Lifecycle Policies

#### Action Plan

- **Set up** lifecycle policies to transition data to lower-cost storage tiers.
- **Define** rules based on data age and access patterns.

#### Metrics

- **Storage Class Analysis**: Monitor to optimize lifecycle rules.
- **Cost per GB Stored**: Reduce by moving data to cheaper tiers.

#### Automated Script

**Configuration File:** `scripts/storage/lifecycle_policy.json`

```json
{
  "Rules": [
    {
      "ID": "Move old objects to Glacier",
      "Status": "Enabled",
      "Filter": {
        "Prefix": ""
      },
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "STANDARD_IA"
        },
        {
          "Days": 90,
          "StorageClass": "GLACIER"
        }
      ],
      "Expiration": {
        "Days": 365
      }
    }
  ]
}
```

**Deployment Command:**

```bash
aws s3api put-bucket-lifecycle-configuration \
    --bucket my-bucket \
    --lifecycle-configuration file://scripts/storage/lifecycle_policy.json
```

---

### 3.2 Delete Unused Data

#### Action Plan

- **Identify** obsolete or redundant data.
- **Remove** unused EBS volumes, snapshots, and unattached resources.

#### Metrics

- **Unused Resources**: Number of orphaned volumes and snapshots.
- **Storage Costs**: Monitor reduction after cleanup.

#### Automated Script

**File:** `scripts/storage/cleanup_ebs_volumes.py`

```python
#!/usr/bin/env python3
# Script: cleanup_ebs_volumes.py
# Description: Delete unattached EBS volumes older than 7 days.

import boto3
from datetime import datetime, timezone, timedelta

def lambda_handler(event, context):
    ec2 = boto3.resource('ec2')
    cutoff = datetime.now(timezone.utc) - timedelta(days=7)
    filters = [
        {'Name': 'status', 'Values': ['available']},
        {'Name': 'create-time', 'Values': [cutoff.strftime('%Y-%m-%dT%H:%M:%S.%fZ')]}
    ]
    volumes = ec2.volumes.filter(Filters=filters)
    for volume in volumes:
        try:
            volume.delete()
            print(f"Deleted volume: {volume.id}")
        except Exception as e:
            print(f"Could not delete volume {volume.id}: {e}")

if __name__ == "__main__":
    lambda_handler(None, None)
```

---

### 3.3 Optimize EBS Volumes

#### Action Plan

- **Analyze** EBS volume utilization.
- **Resize** volumes or switch to appropriate volume types.

#### Metrics

- **Volume Utilization**: Compare allocated vs. used storage.
- **IOPS Utilization**: Ensure volumes match performance needs.

#### Automated Script

**File:** `scripts/storage/ebs_recommendations.sh`

```bash
#!/bin/bash
# Script: ebs_recommendations.sh
# Description: Retrieve EBS volume optimization recommendations.

aws compute-optimizer get-ebs-volume-recommendations \
    --query 'volumeRecommendations[*].{VolumeId:volumeArn, CurrentType:currentConfiguration.volumeType, RecommendedType:recommendationOptions[0].configuration.volumeType}' \
    --output table
```

---

### 3.4 Use Storage Classes Effectively

#### Action Plan

- **Review** S3 storage classes in use.
- **Assign** objects to the most cost-effective storage class based on access patterns.

#### Metrics

- **Access Frequency**: Data accessed less frequently can be moved to Infrequent Access or Glacier.
- **Cost Savings**: Monitor reduction in storage costs.

#### Automated Script

**Configuration File:** `scripts/storage/s3_tiering_config.json`

```json
{
  "Id": "IntelligentTieringConfiguration",
  "Status": "Enabled",
  "Tierings": [
    {
      "Days": 30,
      "AccessTier": "ARCHIVE_ACCESS"
    },
    {
      "Days": 60,
      "AccessTier": "DEEP_ARCHIVE_ACCESS"
    }
  ]
}
```

**Deployment Command:**

```bash
aws s3api put-bucket-intelligent-tiering-configuration \
    --bucket my-bucket \
    --id MyConfiguration \
    --intelligent-tiering-configuration file://scripts/storage/s3_tiering_config.json
```

---

## 4. Tracking Progress with Metrics

#### Define Key Performance Indicators (KPIs)

- **Total AWS Spend**: Overall monthly cost.
- **Cost per Service**: Detailed breakdown.
- **Resource Utilization Rates**: CPU, memory, storage.
- **Cost Savings Achieved**: Quantify monthly savings.

#### Use AWS Tools for Monitoring

- **AWS Cost Explorer**: Visualize cost trends.
- **AWS Budgets**: Set and track budgets.
- **AWS Cost and Usage Reports**: Access detailed billing data.
- **AWS CloudWatch**: Monitor operational metrics.

---

## 5. Reporting and Documentation

### Regular Reports

- **Monthly Cost Optimization Report**:
  - **Executive Summary**: Key achievements.
  - **Detailed Analysis**: Cost breakdown and actions taken.
  - **Visuals**: Graphs of cost trends and savings.
- **Optimization Action Logs**:
  - **Actions Taken**: Document each step.
  - **Impact Analysis**: Effect on cost and performance.
  - **Recommendations**: Future optimization opportunities.

### Demonstrate Improvements

- **Before and After Comparisons**:
  - **Cost Metrics**: Show reductions.
  - **Performance Metrics**: Ensure no degradation.
- **Case Studies**:
  - **Examples**: Highlight significant optimizations.
  - **Lessons Learned**: Share insights.

---

## 6. Automation Recommendations and Scripts

### 6.1 Infrastructure as Code (IaC)

#### Tools

- **AWS CloudFormation**: Automate resource provisioning.
- **HashiCorp Terraform**: Manage infrastructure across providers.

#### Benefits

- **Consistency**: Standardize configurations.
- **Repeatability**: Easily replicate environments.
- **Version Control**: Track changes via code repositories.

#### Example Script

**CloudFormation Template:** `scripts/automation/ec2_instance.yaml`

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: Create an EC2 instance
Resources:
  EC2Instance:
    Type: 'AWS::EC2::Instance'
    Properties:
      InstanceType: t2.micro
      ImageId: ami-0abcdef1234567890
      KeyName: my-key-pair
      SecurityGroupIds:
        - sg-0123456789abcdef0
      SubnetId: subnet-0abcdef1234567890
```

**Deployment Command:**

```bash
aws cloudformation create-stack \
    --stack-name my-ec2-stack \
    --template-body file://scripts/automation/ec2_instance.yaml
```

---

### 6.2 Automated Instance Scheduling

#### Action Plan

- **Identify** non-critical instances that can be stopped during off-hours.
- **Implement** start/stop schedules using AWS Lambda and CloudWatch Events.

#### Automated Script

**Lambda Function:** `scripts/automation/stop_instances.py`

```python
#!/usr/bin/env python3
# Script: stop_instances.py
# Description: Stop EC2 instances on a schedule.

import boto3

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    instances = ['i-0123456789abcdef0', 'i-0fedcba9876543210']
    ec2.stop_instances(InstanceIds=instances)
    print(f"Stopped instances: {instances}")

if __name__ == "__main__":
    lambda_handler(None, None)
```

---

### 6.3 Resource Cleanup Automation

#### Action Plan

- **Schedule** regular cleanup of unused resources.
- **Automate** deletion of unattached EBS volumes, unused Elastic IPs, etc.

#### Automated Scripts

**Lambda Function for Snapshot Cleanup:** `scripts/automation/cleanup_snapshots.py`

```python
#!/usr/bin/env python3
# Script: cleanup_snapshots.py
# Description: Delete EBS snapshots older than 30 days.

import boto3
from datetime import datetime, timezone, timedelta

def lambda_handler(event, context):
    ec2 = boto3.client('ec2')
    snapshots = ec2.describe_snapshots(OwnerIds=['self'])['Snapshots']
    cutoff = datetime.now(timezone.utc) - timedelta(days=30)
    for snapshot in snapshots:
        if snapshot['StartTime'] < cutoff:
            try:
                ec2.delete_snapshot(SnapshotId=snapshot['SnapshotId'])
                print(f"Deleted snapshot: {snapshot['SnapshotId']}")
            except Exception as e:
                print(f"Could not delete snapshot {snapshot['SnapshotId']}: {e}")

if __name__ == "__main__":
    lambda_handler(None, None)
```

**Lambda Function for RDS Instance Stop:** `scripts/automation/stop_rds_instances.py`

```python
#!/usr/bin/env python3
# Script: stop_rds_instances.py
# Description: Stop RDS instances on a schedule.

import boto3

def lambda_handler(event, context):
    rds = boto3.client('rds')
    instances = ['my-db-instance-1', 'my-db-instance-2']
    for instance in instances:
        try:
            rds.stop_db_instance(DBInstanceIdentifier=instance)
            print(f"Stopped RDS instance: {instance}")
        except Exception as e:
            print(f"Could not stop RDS instance {instance}: {e}")

if __name__ == "__main__":
    lambda_handler(None, None)
```

---

## 7. Continuous Improvement Process

### Regular Audits

- **Frequency**: Conduct monthly reviews.
- **Activities**:
  - **Resource Inventory**: Update list of AWS resources.
  - **Cost Analysis**: Review billing for anomalies.
  - **Identify Optimization Opportunities**: Find new areas to save costs.

### Stakeholder Engagement

- **Communication**:
  - **Share Reports**: Keep stakeholders informed.
  - **Feedback Loop**: Gather input on performance impacts.
- **Training**:
  - **Educate Teams**: Promote cost-awareness.

---

## 8. Conclusion

By systematically applying this framework, you can effectively optimize costs across compute, networking, and storage services in AWS. Tracking progress with defined metrics and regularly reporting on improvements ensures transparency and accountability. Automation plays a key role in maintaining cost efficiency and allows your team to focus on strategic initiatives rather than manual tasks.

---

## 9. Next Steps

1. **Initiate Resource Assessment**: Begin with a comprehensive analysis of current AWS resource utilization.
2. **Set Baseline Metrics**: Establish current cost and performance metrics to measure future improvements.
3. **Develop an Action Plan**: Prioritize optimization activities based on potential impact.
4. **Implement Automation Tools**: Start automating repetitive tasks and monitoring.
5. **Schedule Regular Reviews**: Set up a calendar for ongoing audits and reporting.

---

## 10. Appendix: Automated Scripts

All automated scripts are located in the `scripts/` directory and are organized by category (compute, networking, storage, automation). Each script includes comments explaining its purpose and usage instructions.

---

# End of Document

By implementing the strategies and automated scripts provided in this framework, you can significantly reduce AWS costs while maintaining or improving system performance. Regular monitoring and optimization will ensure that your AWS environment remains cost-effective over time.

---

**Note:** Ensure that you have the necessary AWS permissions and credentials configured before running the scripts. Test all scripts in a non-production environment to validate their behavior.

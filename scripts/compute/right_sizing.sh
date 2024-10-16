
#!/bin/bash
# Script: right_sizing.sh
# Description: Retrieve EC2 instance right-sizing recommendations.

# Get recommendations for EC2 instances
aws compute-optimizer get-ec2-instance-recommendations \
    --query 'instanceRecommendations[*].{InstanceId:instanceId, CurrentType:currentInstanceType, RecommendedType:recommendationOptions[0].instanceType}' \
    --output table

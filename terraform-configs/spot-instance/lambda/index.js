const AWS = require('aws-sdk');
const EC2 = new AWS.EC2();

// Create EC2 snapshot based on volume id
function ec2CreateSnapshot(ec2VolumeId) {
    let params = {
        VolumeId: ec2VolumeId,
        Description: 'It is automatically created snapshot and resource volume id: ' + ec2VolumeId,
        TagSpecifications: [
            {
                ResourceType: 'snapshot',
                Tags: [
                    {
                        Key: 'Name',
                        Value: 'Spot-Instance'
                    }
                ]
            }

        ]
    };
    return EC2.createSnapshot(params).promise();
}


// Get EC2 instances based on tag key or instance id
function getEc2Instances(tagKey, instanceId, volumeId) {
    let filters = [];
    if (tagKey) {
        filters.push(
            {
                Name: 'tag:' + tagKey,
                Values: ['true']
            }
        );
    }
    if (instanceId) {
        filters.push(
            {
                Name: 'instance-id',
                Values: [instanceId]
            }
        );
    }
    if (volumeId) {
        filters.push(
            {
                Name: 'block-device-mapping.volume-id',
                Values: [volumeId]
            }
        );
    }
    console.log('filter details for describe instance', filters);
    return EC2.describeInstances({
        Filters: filters
    }).promise();
}

async function handleEc2CreateSnapshotForRootVolume(instanceId) {
    try {
        let ec2Reservations = await getEc2Instances("spot-instance", instanceId);
        let instance = ec2Reservations.Reservations[0].Instances[0];
        let rootDeviceName = instance.RootDeviceName;
        for (let i = 0; i < instance.BlockDeviceMappings.length; i++) { // Create snapshot for root device volume
            if (instance.BlockDeviceMappings[i].DeviceName === rootDeviceName) {
                let createdEc2Snapshot = await ec2CreateSnapshot(instance.BlockDeviceMappings[i].Ebs.VolumeId);
                console.log('root volume snapshot created:', createdEc2Snapshot);
                break;
            }
        }
    } catch (err) {
        console.log('error in taking snapshot of root volume', JSON.stringify(err));
        throw err;
    }
}

exports.handler = async (event) => {
    console.log('Received event: ', JSON.stringify(event, null, 2));
    try {
        // When Instance is stopped, we will take root volume snapshot first.
        if (event['detail-type'] === 'EC2 Instance State-change Notification' && event.detail['instance-id'] && event.detail.state === 'stopped') {
            await handleEc2CreateSnapshotForRootVolume(event.detail['instance-id']);
            console.log("Snapshot is created");
            return ;
        }
        console.log("No Need to process to this event");
        return ;
    } catch (err) {
        console.error(err);
        throw err;
    }
};

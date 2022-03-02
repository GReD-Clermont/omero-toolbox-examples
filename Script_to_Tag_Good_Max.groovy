//@ String(label="Username") username
//@ String(label="Password", style='password', persist=false) password
//@ String(label="Host", value='omero.igred.fr') host
//@ Integer(label="Port", value=4064) port
//@ Integer(label="Group", value=203) group
//@ Long(label="Dataset ID") datasetId
//@ Long(label="Tag ID to link") tagId
//@ Integer(label="Channel", min=1) channel
//@ Integer(label="Min value", value=5000) minValue
//@ Integer(label="Max value", min=20000) maxValue

import fr.igred.omero.Client

Client client = new Client();
client.connect(host, port, username, password.toCharArray(), group);

dataset = client.getDataset(datasetId);
images = dataset.getImages(client);

for(image : images) {
	max = image.getChannels(client).get(channel - 1).asChannelData().getGlobalMax();
	if(max < minValue || max > maxValue) {
		image.addTag(client, tagId);
	}
}

client.disconnect();

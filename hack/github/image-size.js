(async () => {
    const kubeVersions = ["v1.16.15"];


    const platforms = [
        "amd64",
        "arm64",
        "arm/v7",
    ];

    const httpsGet = (url) => new Promise((resolve, reject) => {
		require('https').get(url, (res) => {
            res.on('data', (d) => {
                if (res.statusCode != 200) {
                    reject(res.statusCode);
                    return;
                }

                resolve(JSON.parse(d));
            });
        }).on('error', reject);
	});

    const readImageSize = async (repo, tag) => {
        var imageSize = {};
        // repo should be in the format of "cloudtogo4edge/kubelet".
        const image = `${repo}:${tag}`;
        const imageSpec = await httpsGet(`https://hub.docker.com/v2/repositories/${repo}/tags/?name=${tag}`);
        if (imageSpec.count != 1) {
            throw new Error(`image ${image} not found`);
        }

        for (const i of imageSpec.results[0].images) {
            var platform = i.architecture;
            if (i.variant) {
                platform += "/" + i.variant;
            }

            imageSize[platform] = {
                Com: (parseFloat(i.size) / (1 << 20)).toFixed(2),
                Ex: 0,
            };
        }

        for (const platform of platforms) {
            require('child_process').execSync(`docker image pull --platform linux/${platform} ${image}`);
            const exSize = require('child_process').execSync(`docker image inspect -f '{{.Size}}' ${image}`);
            imageSize[platform].Ex = (parseFloat(exSize, 10) / (1 << 20)).toFixed(2);
        }

        return imageSize;
    }

    const imageCategory = [
        "alpine3.13",
        "flannel-alpine3.13",
        "cni-alpine3.13",
        "kubeadm-alpine3.13",
        "kubeadm-cni-alpine3.13"
    ];

    var readmeSegments = [];

    for (const version of kubeVersions) {
        var readme = `#### ${version}

[\`cloudtogo4edge/kubelet ${version}\`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=${version})

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |`;

        for (const category of imageCategory) {
            const imageSize = await readImageSize("cloudtogo4edge/kubelet", `${version}-${category}`);
            readme += `|[\`${version}-${category}\`]()| \`${imageSize.amd64.Com}MB / ${imageSize.amd64.Ex}MB\`|\`${imageSize.arm64.Com}MB / ${imageSize.arm64.Ex}MB\`|\`${imageSize["arm/v7"].Com}MB / ${imageSize["arm/v7"].Ex}MB\`|`;
        }

        readmeSegments.push(readme);
    }

    console.log(readmeSegments)
})()
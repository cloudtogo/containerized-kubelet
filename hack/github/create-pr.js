const { Octokit } = require("@octokit/rest");

const octokit = new Octokit({
	auth: "",
	previews: ['jean-grey', 'symmetra'],
	log: {
	    debug: () => {},
	    info: console.log,
	    warn: console.warn,
	    error: console.error
	 },
});

(async () => {
	const defaultLabel = "release";

	const issues = await octokit.rest.issues.listForRepo({
		owner: "cloudtogo",
		repo: "containerized-kubelet",
		state: "open",
		per_page: 30,
		page: 1,
	});

	if (issues.status != 200) {
		console.error("[issue] http failure %d", issues.status);
		throw new Error("http failure");
	}

	var targetIssues = [];
	for (const issue of issues.data) {
		if (issue.labels.map(l => l.name).includes(defaultLabel)) {
			targetIssues.push(issue);
		}
	}
	
	if (targetIssues.length == 0) {
		console.log("No issue found");
		return
	}

	targetIssues.map(i => { console.log("found image request of version %s", i.labels.map(l => l.name)) });

	console.log("Found %d issues.", targetIssues.length);
	
	const issue = targetIssues[0];
	if (targetIssues.length > 1) {
		console.log("Only the first issue #%d will be handled in this flow.", issue.id);
	}

	if (issue.pull_request) {
		console.log("Issue %d has already been a PR. Wait it complete.", issue.number);
		return
	}

	console.log("the target issue: ", issue);
	
	console.log("Generating README.md for new releases");
	const imageSize = {
		amd64Com: 0,
		amd64Ex: 0,
		arm64Com: 0,
		arm64Ex: 0,
		amr32v7Com: 0,
		amr32v7Ex: 0,
	};

	var readmeSegments = [];
	const kubeVersions = issue.labels.reduce((versions, l) => { if (l.name != defaultLabel) versions.push(l.name); return versions;}, []);
	kubeVersions.reverse();
	for (const version of kubeVersions) {
		const imageData = {
			version: version,
			size: {
				kubelet: imageSize,
				flannel: imageSize,
				cni: imageSize,
				kubeadm: imageSize,
				kubeadmCNI: imageSize,
			},
		};

		const kubeletReadMeTmpl = `#### ${imageData.version}

[\`cloudtogo4edge/kubelet ${imageData.version}\`](https://hub.docker.com/r/cloudtogo4edge/kubelet/tags?page=1&ordering=last_updated&name=${imageData.version})

| Tag | amd64 | arm64 | arm32v7 |
| --- | --- | --- | --- |
|[\`${imageData.version}-alpine3.13\`]()| \`${imageData.size.kubelet.amd64Com}MB / ${imageData.size.kubelet.amd64Ex}MB\`|\`${imageData.size.kubelet.arm64Com}MB / ${imageData.size.kubelet.arm64Ex}MB\`|\`${imageData.size.kubelet.amr32v7Com}MB / ${imageData.size.kubelet.amr32v7Ex}MB\`|
|[\`${imageData.version}-flannel-alpine3.13\`]()| \`${imageData.size.flannel.amd64Com}MB / ${imageData.size.flannel.amd64Ex}MB\`|\`${imageData.size.flannel.arm64Com}MB / ${imageData.size.flannel.arm64Ex}MB\`|\`${imageData.size.flannel.amr32v7Com}MB / ${imageData.size.flannel.amr32v7Ex}MB\`|
|[\`${imageData.version}-cni-alpine3.13\`]()| \`${imageData.size.cni.amd64Com}MB / ${imageData.size.cni.amd64Ex}MB\`|\`${imageData.size.cni.arm64Com}MB / ${imageData.size.cni.arm64Ex}MB\`|\`${imageData.size.cni.amr32v7Com}MB / ${imageData.size.cni.amr32v7Ex}MB\`|
|[\`${imageData.version}-kubeadm-alpine3.13\`]()| \`${imageData.size.kubeadm.amd64Com}MB / ${imageData.size.kubeadm.amd64Ex}MB\`|\`${imageData.size.kubeadm.arm64Com}MB / ${imageData.size.kubeadm.arm64Ex}MB\`|\` ${imageData.size.kubeadm.amr32v7Com}MB / ${imageData.size.kubeadm.amr32v7Ex}MB\`|
|[\`${imageData.version}-kubeadm-cni-alpine3.13\`]()| \`${imageData.size.kubeadmCNI.amd64Com}MB / ${imageData.size.kubeadmCNI.amd64Ex}MB\`|\`${imageData.size.kubeadmCNI.arm64Com}MB / ${imageData.size.kubeadmCNI.arm64Ex}MB\`|\`${imageData.size.kubeadmCNI.amr32v7Com}MB / ${imageData.size.kubeadmCNI.amr32v7Ex}MB\`|
`;
		readmeSegments.push(kubeletReadMeTmpl);
	}

	const kubeproxyReadMeTmpl = `#### Alpine 3.13 based kube-proxy image

[\`cloudtogo4edge/kube-proxy\`](https://hub.docker.com/r/cloudtogo4edge/kube-proxy)
	
${kubeVersions.map(v => `* [\`${v}-alpine3.13\`]()`).join("\n")}`;

	readmeSegments.push(kubeproxyReadMeTmpl);

	console.log("Fetching master");
	const master = await octokit.rest.git.getRef({
		owner: "cloudtogo",
		repo: "containerized-kubelet",
		ref: "heads/master",
	})

	console.log("Fetching HEAD");
	const headCommit = await octokit.rest.git.getCommit({
		owner: "cloudtogo",
		repo: "containerized-kubelet",
		commit_sha: master.data.object.sha,
	});

	console.log("Fetching HEAD tree");
	var headTree = await octokit.rest.git.getTree({
		owner: "cloudtogo",
		repo: "containerized-kubelet",
		tree_sha: headCommit.data.tree.sha,
	});

	if (headTree.data.truncated) {
		throw new Error("head tree is truncated");
	}

	console.log("Loading the local README template");
	const readReadMeTemplate = () => new Promise((resolve, reject) => {
		require('fs').readFile('README.md.tmpl', {encoding: 'utf8'}, (err, data) => {
			if (err) {
				reject(err);
				return;
			}

			resolve(data);
		});
	});
	var data = await readReadMeTemplate();
	const placeholder = '==IMAGE-README-PLACEHOLDER==';

	console.log("Creating new README blob");
	const newReadMe = await octokit.rest.git.createBlob({
		owner: "cloudtogo",
		repo: "containerized-kubelet",
		content: data.replace(placeholder, readmeSegments.join("\n")),
		encoding: "utf-8",
	});

	for (var treeItem of headTree.data.tree) {
		if (treeItem.path == "README.md") {
			treeItem.sha = newReadMe.data.sha;
			treeItem.url = newReadMe.data.url
			break
		}
	}

	console.log("Creating new commit tree");
	const newTree = await octokit.rest.git.createTree({
		owner: "cloudtogo",
		repo: "containerized-kubelet",
		tree: headTree.data.tree,
	});

	console.log("Committing new README");
	const newCommit = await octokit.rest.git.createCommit({
        owner: "cloudtogo",
		repo: "containerized-kubelet",
		message: "Updates README for new releases " + kubeVersions.join(' '),
		tree: newTree.data.sha,
		parents: [ master.data.object.sha ],
		author: {
			name: "Kitt Hsu",
			email: "kitt.hsu@gmail.com"
		}
    })

	const branch = "bot-release-" + kubeVersions[0];

	console.log("Committing new brach %s", branch);
	const branchRefReq = {
		owner: "cloudtogo",
		repo: "containerized-kubelet",
		ref: "heads/" + branch,
	};

	try {
		await octokit.rest.git.getRef(branchRefReq)
		await octokit.rest.git.deleteRef(branchRefReq);
	} catch (error) {
	}
	
	await octokit.rest.git.createRef({
		owner: "cloudtogo",
		repo: "containerized-kubelet",
		ref: "refs/heads/" + branch,
		sha: newCommit.data.sha,
	});
	
	console.log("Creating the new PR");
	const newPR = await octokit.rest.pulls.create({
		owner: "cloudtogo",
		repo: "containerized-kubelet",
		head: branch,
		base: "master",
		issue: issue.number,
	});

	console.log("Setting labels for the new PR");
	await octokit.rest.issues.update({
		owner: "cloudtogo",
		repo: "containerized-kubelet",
	  	issue_number: newPR.data.number,
		labels: issue.labels,
	});

	console.log("PR created");
})();

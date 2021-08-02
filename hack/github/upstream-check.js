const { Octokit } = require("@octokit/rest");

const octokit = new Octokit({
	auth: "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",
	previews: ['jean-grey', 'symmetra'],
	log: {
	    debug: () => {},
	    info: console.log,
	    warn: console.warn,
	    error: console.error
	 },
});

(async () => {
	const [releases, prs] = await Promise.all([
		octokit.rest.repos.listReleases({
			owner: "kubernetes",
			repo: "kubernetes",
			per_page: 30,
			page: 1,
		}),
		octokit.rest.issues.listForRepo({
			owner: "cloudtogo",
			repo: "containerized-kubelet",
			state: "all",
			per_page: 30,
			page: 1,
		}),
	]);

	var issueLabels = {};
	if (prs.status != 200) {
		console.error("[pr] http failure %d", prs.status);
		throw new Error("http failure");
	}

	for (const pr of prs.data) {
		if (pr.labels.length > 0) {
			for (const label of pr.labels) {
				issueLabels[label.name] = true;
			}
			break;
		}
	}

	if (issueLabels.length == 0) {
		console.error("no label found in PR");
		throw new Error("no label found in PR");
	}

	console.log("PR labels ", issueLabels);
	
	if (releases.status != 200) {
		console.error("[kubernetes] http failure %d", releases.status);
		throw new Error("http failure");
	}

	var newReleases = [];
	var latestRel = "";
	for (const rel of releases.data) {
		if (!rel.rel && rel.tag_name.match(/^v\d+\.\d+\.\d+$/)) {
			if (issueLabels[rel.tag_name]) {
				break;
			}

			console.log("found release %s", rel.name);
			newReleases.push(rel.tag_name);
			if (latestRel == "") {
				latestRel = rel.tag_name;
			}
		}
	}

	console.log("New releases ", newReleases);

	const newIssue = await octokit.rest.issues.create({
		owner: "cloudtogo",
		repo: "containerized-kubelet",
		title: "Build images for upgrade upstream LTS",
		labels: newReleases.map((rel) => rel),
		body: "This issue is created by a periodically running robot, for building images of the latest kubernetes LTS.",
	});
	if (newIssue.status != 201) {
		console.error("[new issue] http failure %d", newIssue.status);
		throw new Error("http failure");
	}

	console.log("Issue for %s created", releases);
})();

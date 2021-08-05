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
	const releaseLabel = "release";
	const [releases, issues] = await Promise.all([
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

	var versionInNumber = (v) => {
		// A version is in the manner of 'v1.xx.xx'.
		var versionDigits = '';
		for (const part of v.slice(1).split('.')) {
			versionDigits += part.padEnd(3, '0');
		}

		return {
			major: parseInt(versionDigits.slice(0, 6)),
			minor: parseInt(versionDigits.slice(6)),
		};
	}

	var builtVersions = {};

	for (const issue of issues.data) {
		if (issue.labels.map(l => l.name).includes(releaseLabel)) {
			if (issue.state == "open") {
				console.log("Issue %d is still pending. Latest releases will be build after that.", issue.number);
				return
			}

			// https://github.com/cloudtogo/containerized-kubelet/issues/13
			if (issue.number != 13 && !issue.pull_request) {
				console.log("Issue %d wasn't merged", issue.number);
				continue;
			}

			if (issue.pull_request) {
				try {
					const merged = await octokit.rest.pulls.checkIfMerged({
						owner: "cloudtogo",
						repo: "containerized-kubelet",
						pull_number: issue.number,
					  });
				} catch (error) {
					console.log("Issue %d wasn't merged", issue.number);
					continue;
				}
			}

			issue.labels.reduce((versions, l) => { if (l.name != releaseLabel) { const v = versionInNumber(l.name); versions[v.major] = v.minor; } return versions;}, builtVersions);
			break;
		}
	}

	if (Object.keys(builtVersions).length == 0) {
		console.error("no label found in issues");
		throw new Error("no label found in issues");
	}

	console.log("Issue labels ", builtVersions);

	var newReleases = [];
	for (const rel of releases.data) {
		if (!rel.rel && rel.tag_name.match(/^v\d+\.\d+\.\d+$/)) {
			const releaseInNumber = versionInNumber(rel.tag_name);
			if (releaseInNumber.major in builtVersions) {
				if (releaseInNumber.minor > builtVersions[releaseInNumber.major]) {
					console.log("found release %s", rel.name);
					newReleases.push(rel.tag_name);
				}
			} else {
				const maxMajor = Object.keys(builtVersions).sort((a, b) => b-a)[0];
				if (releaseInNumber.major > maxMajor) {
					console.log("found new major release %s", rel.name);
					newReleases.push(rel.tag_name);
				}
			}
		}
	}

	console.log("New releases ", newReleases);
	if (newReleases.length == 0) {
		console.log("No new release found");
		return
	}

	newReleases.push(releaseLabel);
	await octokit.rest.issues.create({
		owner: "cloudtogo",
		repo: "containerized-kubelet",
		title: "Build images for upgrade upstream LTS",
		labels: newReleases.map((rel) => rel),
		body: "This issue is created by a periodically running robot, for building images of the latest kubernetes LTS.",
	});

	console.log("Issue for %s created", releases);
})();

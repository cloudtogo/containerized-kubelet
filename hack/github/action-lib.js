const releaseLabel = "release";

const readFile = (f) => new Promise((resolve, reject) => {
  require('fs').readFile(f, {encoding: 'utf8'}, (err, data) => {
    if (err) {
      reject(err);
      return;
    }

    resolve(data);
  });
});

// file = { path: "", data: ""}
module.exports.commitRootFile = async (github, branch, file, comment) => {
    if (branch.startsWith("refs/")) {
      branch = branch.slice(5);
    }

    console.log("Fetching %s", branch);

    const head = await github.git.getRef({
      owner: "cloudtogo",
      repo: "containerized-kubelet",
      ref: branch,
    })

    console.log("Fetching latest commit on branch %s", branch);
    const headCommit = await github.git.getCommit({
      owner: "cloudtogo",
      repo: "containerized-kubelet",
      commit_sha: head.data.object.sha,
    });

    console.log("Fetching HEAD tree");
    var headTree = await github.git.getTree({
      owner: "cloudtogo",
      repo: "containerized-kubelet",
      tree_sha: headCommit.data.tree.sha,
    });

    if (headTree.data.truncated) {
      throw new Error("head tree is truncated");
    }

    if (!file.data) {
      file.data = await readFile(file.path);
    }

    console.log("Creating blob for %s", file.path);
    const { data: blob } = await github.git.createBlob({
      owner: "cloudtogo",
      repo: "containerized-kubelet",
      content: file.data,
      encoding: "utf-8",
    });

    var found = false;
    for (var treeItem of headTree.data.tree) {
      if (treeItem.path == file.path) {
        treeItem.sha = blob.sha;
        treeItem.url = blob.url;
        found = true;
        break
      }
    }

    if (!found) {
      headTree.data.tree.push({
        path: file.path,
        type: "blob",
        sha: blob.sha,
        url: blob.url,
      });
    }

    console.log("Creating new commit tree");
    const newTree = await github.git.createTree({
      owner: "cloudtogo",
      repo: "containerized-kubelet",
      tree: headTree.data.tree,
    });

    console.log("Committing %s", file.path);
    const newCommit = await github.git.createCommit({
      owner: "cloudtogo",
      repo: "containerized-kubelet",
      message: comment,
      tree: newTree.data.sha,
      parents: [ head.data.object.sha ],
      author: {
        name: "Kitt Hsu",
        email: "kitt.hsu@gmail.com"
      }
    })

    await github.git.updateRef({
      owner: "cloudtogo",
      repo: "containerized-kubelet",
      ref: branch,
      sha: newCommit.data.sha,
    });
}

module.exports.checkUpstreamRelease = async (github) => {
  const [releases, issues] = await Promise.all([
    github.repos.listReleases({
      owner: "kubernetes",
      repo: "kubernetes",
      per_page: 30,
      page: 1,
    }),
    github.issues.listForRepo({
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
          const merged = await github.pulls.checkIfMerged({
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
  await github.issues.create({
    owner: "cloudtogo",
    repo: "containerized-kubelet",
    title: "Build images for upgrade upstream LTS",
    labels: newReleases.map((rel) => rel),
    body: "This issue is created by a periodically running robot, for building images of the latest kubernetes LTS.",
  });

  console.log("Issue for %s created", releases);
}

module.exports.readKubeVersionFromLabels = () => {
  var kubeVersions = process.env.ISSUE_LABELS.split(" ").reduce((versions, l) => { if (l != releaseLabel) versions.push(l); return versions;}, []);
  kubeVersions.sort();
  kubeVersions.reverse();
  return kubeVersions;
}

module.exports.createPRForNewReleases = async (github) => {
    const { ISSUE_NUMBER } = process.env;

    console.log("the target issue: %s", ISSUE_NUMBER);

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
    const kubeVersions = module.exports.readKubeVersionFromLabels();
    console.log("build PR for versions ", kubeVersions);

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

    console.log("Loading the local README template");
    var data = await readFile('hack/github/README.md.tmpl');
    const placeholder = '==IMAGE-README-PLACEHOLDER==';
    const readmeBlob = data.replace(placeholder, readmeSegments.join("\n"));
    const branch = "bot-release-" + kubeVersions[0];

    console.log("Committing new brach %s", branch);
    const branchRefReq = {
      owner: "cloudtogo",
      repo: "containerized-kubelet",
      ref: "heads/" + branch,
    };

    try {
      await github.git.getRef(branchRefReq)
      await github.git.deleteRef(branchRefReq);
    } catch (error) {
    }

    await github.git.createRef({
      owner: "cloudtogo",
      repo: "containerized-kubelet",
      ref: "refs/heads/" + branch,
      sha: process.env.GITHUB_SHA,
    });

    await module.exports.commitRootFile(github, "refs/heads/" + branch, { path: "README.md", data: readmeBlob}, "Updates README for new releases " + kubeVersions.join(' '));
  
    console.log("Creating the new PR");
    await github.pulls.create({
      owner: "cloudtogo",
      repo: "containerized-kubelet",
      head: branch,
      base: "master",
      issue: parseInt(ISSUE_NUMBER),
    });

    console.log("PR created");
}

module.exports.updateImageSizeInPR = async (github) => {
  const kubeVersions = module.exports.readKubeVersionFromLabels();

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

  const kubeproxyReadMeTmpl = `#### Alpine 3.13 based kube-proxy image

  [\`cloudtogo4edge/kube-proxy\`](https://hub.docker.com/r/cloudtogo4edge/kube-proxy)

  ${kubeVersions.map(v => `* [\`${v}-alpine3.13\`]()`).join("\n")}`;

  readmeSegments.push(kubeproxyReadMeTmpl);

  var data = await readReadMeTemplate('README.md.tmpl');
  const placeholder = '==IMAGE-README-PLACEHOLDER==';
  const readmeBlob = data.replace(placeholder, readmeSegments.join("\n"));

  await module.exports.commitRootFile(github, process.env.GITHUB_REF, { path: "README.md", data: readmeBlob}, "Updates image size for new releases " + kubeVersions.join(' '));
}

module.exports.commentPR = async (github, comment) => {
    await github.issues.createComment({
      owner: "cloudtogo",
      repo: "containerized-kubelet",
      issue_number: process.env.ISSUE_NUMBER,
      body: comment,
    });
}

module.exports.commentForImageBuilding = async (github) => {
  await module.exports.commentPR(github, "/build");
}

module.exports.commentForE2E = async (github) => {
  await module.exports.commentPR(github, "/e2e");
}

module.exports.commentForSizeCalc = async (github) => {
  await module.exports.commentPR(github, "/size");
}
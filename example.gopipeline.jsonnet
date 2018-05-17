
////////////////////////////////////////////////////////////////////////////
// The pipeline definition for build-h2o
////////////////////////////////////////////////////////////////////////////

local go = import "go.libjsonnet";

// H2O container build pipeline
go.pipeline("build-h2o", "h2o") + {

    // Single git repo as input
    materials: [
	go.git("h2o", "git@github.com:cybermaggedon/h2o", null)
    ],

    stages: [

	// Build stage, creates docker container which is pushed.  Also
	// creates the ksonnet which is used to deploy.
	go.stage("build") + {
	    jobs: [
		go.job("build") + {
		    tasks: [

			// make all push
			go.make(["all", "push"]),

			// Write the version number of the container to a file.
			go.exec("sh", [
			    "-c",
			    "make version > version"
			]),

			// Put the quoted version number in a JSONNET file.
			go.exec("sh", [
			    "-c",
			    "echo '\"'$(cat version)'\"' " +
				"> version.jsonnet"
			])
		    ],

		    // The ksonnet directory provides cluster deployment
		    // definition.  Also pass on the version number to
		    // a deploy pipeline.
		    artifacts: [
			go.artifact("ksonnet", "build"),
			go.artifact("version.jsonnet", "build")
		    ]

		}
	    ]
	}

    ]
}

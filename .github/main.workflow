workflow "Build libskeleton" {
  on = "deployment"
  resolves = ["libskeletonBuildActions"]
}

action "libskeletonBuildActions" {
  uses = "./"
}

using TestItemRunner

# The main purpose of this package is to provide data files that are downloaded
# on demand. Downloading them takes time and bandwidth, so the test suite can be
# restricted to a subset of the `@testitem`s by setting the `TRIXIDATA_TEST`
# environment variable to one of the tags used below. In particular,
# `TRIXIDATA_TEST=quality` runs the tests that work without network access.
# By default (`TRIXIDATA_TEST=all`), all test items are run.
const TRIXIDATA_TEST = get(ENV, "TRIXIDATA_TEST", "all")

# With `TRIXIDATA_TEST_VERBOSE=true`, `@run_package_tests` prints every
# `@testitem` (together with its run time) in the final test summary instead of
# only the failing ones.
const TRIXIDATA_TEST_VERBOSE = get(ENV, "TRIXIDATA_TEST_VERBOSE", "false") == "true"

testitem_filter = ti -> TRIXIDATA_TEST == "all" || Symbol(TRIXIDATA_TEST) in ti.tags

@run_package_tests filter=testitem_filter verbose=TRIXIDATA_TEST_VERBOSE

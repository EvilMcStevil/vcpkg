// The portions of TMC that require standalone compilation will be compiled in
// this file due to the presence of the TMC_IMPL macro.
// Other files should not define TMC_IMPL, and should include the headers only.

#define TMC_IMPL
#include "include/tmc/all_headers.hpp" // IWYU pragma: keep
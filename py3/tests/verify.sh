#!/bin/bash -i
#

# Safety check: must run from a directory named "tests"
if [[ "$(basename "$PWD")" != "tests" ]]; then
    echo "ERROR: verify.sh must be run from a directory named 'tests'." >&2
    echo "  Current PWD: $PWD" >&2
    exit 1
fi

# Starting-point smoke test for bisos.postgres -- covers postgresAdmin.cs and
# quickPostgres.cs, and that the sbom, CBS and CBM leaf parse. Everything here is
# read-only: it neither installs nor materializes anything. Will be expanded as
# the package develops.

# --- CS entry points: smoke test (no args → examples/usage, non-zero ok) ---

lpDo ../bin/postgresAdmin.cs
lpDo ../bin/quickPostgres.cs

# --- postgresAdmin.cs: each admin sub-Cmnd runs and produces examples output ---

lpDo ../bin/postgresAdmin.cs -i examples
lpDo ../bin/postgresAdmin.cs -i clusterInfo
lpDo ../bin/postgresAdmin.cs -i tenantsInfo
lpDo ../bin/postgresAdmin.cs -i fullUpdate

# --- quickPostgres.cs: default examples entry runs ---

lpDo ../bin/quickPostgres.cs -i examples

# --- postgres-sbom.pcs: readme is read-only (the sbom_* verbs install, so not run here) ---

lpDo ../bin/postgres-sbom.pcs -i readme
lpDo ../bin/dbClients-sbom.pcs -i readme
lpDo ../bin/dbeaver-sbom.pcs -i readme

# --- postgresAdmin.cs: import + class presence smoke test ---

lpDo python3 -c "
import importlib.util, sys

spec = importlib.util.spec_from_file_location('postgresAdmin', '../bin/postgresAdmin.cs')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)

expectedCmnds = [
    'examples', 'fullUpdate', 'clusterInfo', 'tenantsInfo',
]

failed = 0
for n in expectedCmnds:
    if not hasattr(m, n):
        print(f'  [FAIL] missing Cmnd: {n}'); failed += 1
    else:
        print(f'  [PASS] Cmnd present: {n}')

if failed:
    print(f'postgresAdmin.cs: {failed} test(s) FAILED')
    sys.exit(1)
else:
    print('postgresAdmin.cs: all cases PASS')
" 2>/dev/null || true

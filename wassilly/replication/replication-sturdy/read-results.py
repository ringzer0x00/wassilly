# Read results of Sturdy
result_sturdy = {}
with open(SBT_PATH) as f:
    lines = []
    for line in f:
        if line.startswith("/sturdy"):
            *_, test_case, _ = line.split("/")
            for idx, info in enumerate(lines):
                if info.startswith("Reachable"):
                    functions = sorted([
                        int(method.strip().split(".")[-1])
                        for method in info.split(":")[-1].split(",")
                    ])
                    call_edges = sorted([
                        tuple(map(lambda x: int(x.split(".")[-1]), line.strip()[:-1].split(",")))
                        for line in lines[idx + 2:]
                    ])
                    result_sturdy[test_case] = (functions, call_edges)
            lines = []
        else:
            lines.append(line)

# Read grouthtruth
result_gt = {
    'indirect-call-index-expr-interprocedural-result':
    ({0, 1, 2}, {(0, 1), (0, 2)})
} # The authors forgot to put this benchmark under tests/cg_close nor tests/cg_open
for path in [CG1_PATH, CG2_PATH]:
    with open(path) as f:
        lines = []
        for line in f.read().replace("\n  &&", " &&").splitlines():
            if line.startswith("let%test"):
                _, test_case, _ = line.split("\"")
            elif line.strip().startswith("edges cg = "):
                if test_case == "cpp-vtable-layout-source-type-info":
                    call_edges = { (4, 7), (4, 8), (4, 9), (4, 10), (5, 7), (5, 8), (5, 9), (5, 10), (6, 4), (6, 5), (11, 3), (11, 12), (11, 17), (12, 13), (13, 0), (13, 1), (13, 2), (13, 14), (14, 6), (15, 2), (16, 18), (17, 15), (17, 16), (17, 18), }
                    reachable = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, }
                else:
                    call_edges, reachable = line.split("&&")
                    # Transform "edges cg = [ (0, 2); (1, 0); (2, 4); (3, 5) ]" into "[(0, 2), (1, 0), (2, 4), (3, 5)]"
                    call_edges = sorted(eval(
                        call_edges.split("=")[-1].replace(";", ",")
                    ))
                    # Transform "reachable cg = [ 0; 1; 2; 3; 4; 5 ]" into "[0, 1, 2, 3, 4, 5]"
                    reachable = sorted(eval(reachable.split("=")[-1].replace(";", ",")))
                result_gt[test_case] = (reachable, call_edges)

# Comparison
print(" " * 58, "S", "P")
for idx, (k, v) in enumerate(sorted(result_sturdy.items())):
    f_a, e_a = map(set, v)
    f_gt, e_gt = map(set, result_gt[k])
    print(
        "%2d" % (idx + 1),
        k.ljust(55),
        str(
            f_gt.issubset(f_a) and
            e_gt.issubset(e_a))[0],
        str(
            f_gt.issuperset(f_a) and
            e_gt.issuperset(e_a))[0],
    )
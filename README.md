# Mark2DOT: weighted graphs from MATLAB

[![MATLAB tests](https://github.com/cmccomb/Mark2DOT/actions/workflows/tests.yml/badge.svg)](https://github.com/cmccomb/Mark2DOT/actions/workflows/tests.yml)

mc_to_dot writes a weighted directed graph from a square matrix. It draws
edges whose weights are greater than the median matrix entry and scales line
widths by weight. This is useful for visualizing Markov transition matrices
and other nonnegative weighted graphs.

    T = [0.1 0.9; 0.7 0.3];
    mc_to_dot('transitions.dot', T, {'Start', 'Finish'});
    mc_to_dot('transitions.png', T, {'Start', 'Finish'});

DOT export needs only MATLAB. PNG, PDF, SVG, and other Graphviz formats need
[Graphviz](https://graphviz.org/) installed and a layout program on your
system PATH. The default layout is circo; pass a fourth argument such as
'dot' or 'neato' to choose another program:

    mc_to_dot('transitions.svg', T, {'Start', 'Finish'}, 'dot');

Omit the labels argument to number the nodes. T must be a nonempty square
matrix of finite, nonnegative weights, with one label per row when labels are
supplied. Labels are escaped in the DOT file. Output filenames can include
spaces and apostrophes.

Run test_mc_to_dot from this folder to check DOT output. The rendering test
runs when Graphviz is installed. GitHub Actions installs Graphviz and runs
both tests on pushes and pull requests.

Licensed under BSD 3-Clause; see [LICENSE](LICENSE).

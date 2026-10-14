%% DOT output works without Graphviz
weights = [0 1; 0 0];
dot_file = [tempname '.dot'];
mc_to_dot(dot_file, weights, {'A "quoted"', 'B'});
dot_text = fileread(dot_file);
assert(contains(dot_text, '1 -> 2'));
assert(~contains(dot_text, '2 -> 1'));
assert(contains(dot_text, 'A \"quoted\"'));
delete(dot_file);

%% Missing labels are generated
dot_file = [tempname '.dot'];
mc_to_dot(dot_file, weights);
dot_text = fileread(dot_file);
assert(contains(dot_text, 'label="1"'));
delete(dot_file);

%% Invalid matrices and renderers fail before writing a file
try
    mc_to_dot([tempname '.dot'], ones(2,3));
    error('Expected an error for a nonsquare matrix.');
catch err
    assert(contains(err.message, 'square matrix'));
end
try
    mc_to_dot([tempname '.dot'], [0 -1; 1 0]);
    error('Expected an error for negative weights.');
catch err
    assert(contains(err.message, 'nonnegative'));
end
try
    mc_to_dot([tempname '.png'], weights, [], 'circo;echo unsafe');
    error('Expected an error for an unknown renderer.');
catch err
    assert(contains(err.message, 'supported Graphviz'));
end

%% Rendered output works if Graphviz is installed
[graphviz_status, ~] = system('circo -V');
if graphviz_status == 0
    image_file = fullfile(tempdir, 'Mark2DOT test with spaces and ''quotes''.png');
    mc_to_dot(image_file, weights, {'A', 'B'});
    assert(exist(image_file, 'file') == 2);
    delete(image_file);
end

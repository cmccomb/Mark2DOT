%% Define inputs for test
tm = [0.3463, 0.0680, 0.5537, 0.0095, 0.0029, 0.0029, 0.0167;
      0.2257, 0.3346, 0.2565, 0.1144, 0.0110, 0.0450, 0.0126;
      0.2108, 0.0311, 0.6616, 0.0398, 0.0091, 0.0207, 0.0269;
      0.0851, 0.2694, 0.1422, 0.4649, 0.0075, 0.0122, 0.0187;
      0.0495, 0.0442, 0.0212, 0.0283, 0.7173, 0.1237, 0.0159;
      0.0106, 0.0092, 0.0065, 0.0116, 0.0082, 0.9388, 0.0150;
      0.0653, 0.0426, 0.1032, 0.0275, 0.0104, 0.1136, 0.6373];
labels = {'Add Joint', 'Remove Joint', 'Add Member', 'Remove Member', 'Size (All)', 'Size (Single)', 'Move Joint'};

%% Begin tests
% Test pdf creation
mc_to_dot('full.pdf', tm, labels);
assert(exist('full.pdf', 'file')==2);
delete('full.pdf');

% Test png creation
mc_to_dot('full.png', tm, labels);
assert(exist('full.png', 'file')==2);
delete('full.png');

% Test dot creation
mc_to_dot('full.dot', tm, labels);
assert(exist('full.dot', 'file')==2);
delete('full.dot');

% Test auto-labeling
mc_to_dot('auto_label.png', tm);
assert(exist('auto_label.png', 'file')==2);
delete('auto_label.png');

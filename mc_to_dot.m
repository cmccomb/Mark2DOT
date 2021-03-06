function mc_to_dot(file_name, T, labels, varargin)
    %% To-do List
    % TODO: Smarter weighting options for edges
    % TODO: Optiont to hide self-transitions
    % TODO: Support different shapes and sizes for nodes
    % TODO: Support different graphviz compilers
    % TODO: Better error messages when checking /usr/bin and /usr/local/bin

    %% Check if labels have been provided. Else, autolabel
    if ~exist('labels', 'var')
        N = length(T);
        for i=1:1:N
            labels{i} = num2str(i);
        end
    end

    %% Open file for editing
    [path, name, extension] = fileparts(file_name);
    if isempty(path)
        path = '.';
    end
    temp_name = tempname;
    f = fopen(temp_name, 'w');

    %% Write headers
    fprintf(f, 'digraph G {\n');

    %% Write labels
    for i=1:1:length(labels)
        fprintf(f, '\t%i[label=%c%s%c, shape=box]\n', i, char(34), labels{i}, char(34));
    end

    %% Write connections
    thresh = median(T(:));
    for i=1:1:length(T)
        for j=1:1:length(T)
            if T(i,j) > thresh
                fprintf(f, '\t%i -> %i [penwidth=%f]\n', i, j, T(i,j)./max(T(:))*6+0.25);
            end
        end
    end

    %% Close the file
    fprintf(f, '}\n');
    fclose(f);

    %% Make the file
    if strcmp(extension, '.dot')
        movefile(temp_name, file_name);
    else
        state = system(['/usr/bin/circo -T' extension(2:end) ' ' temp_name ' -o ' file_name]);
        if state ~= 0
            state = system(['/usr/local/bin/circo -T' extension(2:end) ' ' temp_name ' -o ' file_name]);
            if state ~= 0
                movefile(temp_name, [path '/' name '.dot']);
            else
                  delete(temp_name);
            end
        else
            delete(temp_name);
        end
    end
end

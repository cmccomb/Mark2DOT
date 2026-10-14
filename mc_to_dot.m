function mc_to_dot(file_name, T, labels, varargin)
%MC_TO_DOT Export a weighted directed graph to DOT or a Graphviz image.
%   MC_TO_DOT(FILE_NAME, T, LABELS) writes edges whose weights exceed the
%   median weight in the square, nonnegative matrix T. LABELS is optional.
%   A .dot file needs no external software. Other extensions use Graphviz.
%
%   MC_TO_DOT(FILE_NAME, T, LABELS, RENDERER) selects a Graphviz layout
%   program such as 'dot', 'circo' (default), or 'neato' from the system PATH.

    if nargin < 2 || nargin > 4
        error('Supply an output filename, a square matrix, and optional labels and renderer.');
    end
    if isstring(file_name) && isscalar(file_name)
        file_name = char(file_name);
    end
    if ~ischar(file_name) || isempty(file_name)
        error('The output filename must be a nonempty character vector or string.');
    end
    if ~isnumeric(T) || ~ismatrix(T) || size(T,1) ~= size(T,2) || ...
            isempty(T) || ~isreal(T) || any(~isfinite(T(:))) || any(T(:) < 0)
        error('T must be a nonempty square matrix of finite nonnegative weights.');
    end

    N = size(T,1);
    if nargin < 3 || isempty(labels)
        labels = arrayfun(@num2str, 1:N, 'UniformOutput', false);
    elseif isstring(labels)
        labels = cellstr(labels);
    end
    if ~iscellstr(labels) || numel(labels) ~= N
        error('Provide one text label per row of T.');
    end

    renderer = 'circo';
    if nargin == 4
        renderer = char(varargin{1});
    end
    valid_renderers = {'dot','circo','neato','fdp','sfdp','twopi','osage','patchwork'};
    if ~any(strcmp(renderer, valid_renderers))
        error('Renderer must be a supported Graphviz layout program.');
    end

    [~, ~, extension] = fileparts(file_name);
    extension = lower(extension);
    if isempty(extension) || isempty(regexp(extension(2:end), '^[a-z][a-z0-9]*$', 'once'))
        error('The output filename must have a Graphviz format extension, such as .dot or .png.');
    end

    temp_dot = [tempname '.dot'];
    cleanup = onCleanup(@() delete_if_exists(temp_dot));
    [fid, message] = fopen(temp_dot, 'w');
    if fid < 0
        error('Could not create temporary DOT file: %s', message);
    end

    fprintf(fid, 'digraph G {\n');
    for i = 1:N
        fprintf(fid, '\t%d [label="%s", shape=box];\n', i, escape_dot_label(labels{i}));
    end

    threshold = median(T(:));
    largest_weight = max(T(:));
    for i = 1:N
        for j = 1:N
            if T(i,j) > threshold
                line_width = T(i,j)/largest_weight*6 + 0.25;
                fprintf(fid, '\t%d -> %d [penwidth=%.6g];\n', i, j, line_width);
            end
        end
    end
    fprintf(fid, '}\n');
    fclose(fid);

    if strcmp(extension, '.dot')
        [status, message] = movefile(temp_dot, file_name, 'f');
        if ~status
            error('Could not write DOT file: %s', message);
        end
        return;
    end

    executable = find_renderer(renderer);
    if isempty(executable)
        error('Graphviz %s was not found on PATH. Export a .dot file or install Graphviz.', renderer);
    end
    format = extension(2:end);
    command = [shell_quote(executable) ' -T' format ' ' ...
               shell_quote(temp_dot) ' -o ' shell_quote(file_name)];
    [status, output] = system(command);
    if status ~= 0
        error('Graphviz could not render %s: %s', file_name, strtrim(output));
    end
end

function escaped = escape_dot_label(label)
    escaped = strrep(label, '\', '\\');
    escaped = strrep(escaped, '"', '\"');
    escaped = strrep(escaped, sprintf('\n'), '\n');
end

function executable = find_renderer(renderer)
    executable = '';
    name = renderer;
    if ispc
        name = [name '.exe'];
    end
    folders = strsplit(getenv('PATH'), pathsep);
    for k = 1:numel(folders)
        candidate = fullfile(folders{k}, name);
        if exist(candidate, 'file') == 2
            executable = candidate;
            return;
        end
    end
end

function quoted = shell_quote(value)
    if ispc
        if any(ismember(value, ['"' '%' '!' '^' '&' '|' '<' '>']))
            error('The Graphviz path contains characters unsupported by Windows command quoting.');
        end
        quoted = ['"' value '"'];
    else
        apostrophe = char(39);
        double_quote = char(34);
        quoted = [apostrophe strrep(value, apostrophe, ...
                  [apostrophe double_quote apostrophe double_quote apostrophe]) apostrophe];
    end
end

function delete_if_exists(file_name)
    if exist(file_name, 'file') == 2
        delete(file_name);
    end
end

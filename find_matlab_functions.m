%% Make a list of all MATLAB functions available
function find_matlab_functions(recurse_packages)
    if nargin == 0
        % Don't recurse packages, there > 500 of them and they contain ~50k functions. The largest one is matlab with
        % ~7k functions.
        recurse_packages = false;
    end

    restoredefaultpath;

    %% Search all the functions
    p = split(path,':');
    f = {};
    packages = containers.Map;
    fprintf('Scanning %d folders... ', length(p));
    for i=1:length(p)
        w = what(p{i});
        f = [f;
            strrep(w.m, '.m', '');
            strrep(w.mlapp, '.mlapp', '')
            strrep(w.mlx, '.mlx', '');
            strrep(w.p, '.p', '');
            w.classes;
        ];

        if recurse_packages
            for j = 1:length(w.packages)
                pack = w.packages{j};

                if ~packages.isKey(pack)
                    fprintf('\n%s: ', pack);

                    m = meta.package.fromName(pack);
                    packages(pack) = check_package(m);
                    f = [f; packages(pack)];

                    fprintf('%d functions.', length(packages(pack)));
                end
            end
        else
            f = [f; w.packages];
        end
    end

    f = unique(f);
    keywords = {'return', 'function', 'switch', 'case', 'else', 'elseif', 'end', 'if', 'otherwise', 'break', ...
        'continue', 'for', 'while', 'classdef', 'methods', 'properties', 'events', 'persistent', 'global', 'try', ...
        'catch', 'rethrow', 'import', 'true', 'false', 'eps', 'pi', 'contains', 'i', 'j'};

    f = sort(setdiff(f, keywords));

    if recurse_packages
        fprintf('\nTotal: ');
    end
    fprintf('Found %d functions.\n', length(f));

    %% Write output file
    if recurse_packages
        fn = 'syntax/_matlab_functions_full.vim';
        save('all', 'f', 'packages')
    else
        fn = 'syntax/_matlab_functions.vim';
    end
    out = fopen(fn, 'w');
    fprintf(out, '" Syntax file with all available MATLAB functions, generated in MATLAB %s\n', version);
    fprintf(out, '" To regenerate this file, launch find_matlab_functions.m\n', version);

    s_prefix = 'syn keyword matlabFunc';
    s = s_prefix;
    for i = 1:length(f)
        c = f{i};
        if length(c) + length(s) + 2 >= 120
            fprintf(out, '%s\n', s);
            s = [s_prefix ' ' c];
        else
            s = [s ' ' c];
        end
    end
    fclose(out);
    fprintf('%s written.\n', fn);
end

%% Recursively add package content to f
function f = check_package(m)
    f = split(m.Name, '.');
    try
        % This fails sometimes, so wrap this in a try. If we don't get all of them, it is fine.
        f = [f; transpose({m.FunctionList.Name})];

        for i =1:length(m.ClassList)
            f = [f; split(m.ClassList(i).Name, '.')];
        end
    end

    % Treat sub-packages
    for i = 1:length(m.PackageList)
        sub = m.PackageList(i);
        f = [f; check_package(sub)];
    end

    f = unique(f);
end

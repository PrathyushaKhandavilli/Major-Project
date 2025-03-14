function options = cnnmoset(varargin)
%
% Print out possible values of properties.
if (nargin == 0) && (nargout == 0)
    fprintf('            Display: [ off | iter | final ]\n');
    fprintf('             TolKKT: [ positive scalar ]\n');
    fprintf('            MaxIter: [ positive scalar ]\n');
    fprintf('   KernelCacheLimit: [ positive scalar ]\n');
    fprintf('  KKTViolationLevel: [ positive scalar]\n');
    fprintf('\n');
    return;
end

% Create a struct of all the fields with all values set to
Options = {...
    'Display', 'off';
    'TolKKT', 1e-3;
    'MaxIter', 15000;
    'KKTViolationLevel', 0;
    'KernelCacheLimit', 5000;};

Names = Options(:,1);
Defaults = Options(:,2);

m = size(Names,1);

% Combine all leading options structures o1, o2, ... in odeset(o1,o2,...).
for j = 1:m
    options.(Names{j}) = Defaults{j};
end
% work through the inputs until we find a parameter name. Handle options
% structures as we go.
i = 1;
while i <= nargin
    arg = varargin{i};
    if ischar(arg)                         % arg is an option name
        break;
    end
    if ~isempty(arg)                      % [] is a valid options argument
        if ~isa(arg,'struct')
            error('Bioinfo:cnnmoset:NoPropNameOrStruct',...
                ['Expected argument %d to be a string property name ' ...
                'or an options structure\ncreated with ODESET.'], i);
        end
        for j = 1:m
            if any(strcmp(fieldnames(arg),Names{j}))
                val = arg.(Names{j});
            else
                val = [];
            end
            if ~isempty(val)
                options.(Names{j}) = val;
            end
        end
    end
    i = i + 1;
end

% A finite state machine to parse name-value pairs.
if rem(nargin-i+1,2) ~= 0
    error('Bioinfo:cnnmoset:ArgNameValueMismatch',...
        'Arguments must occur in name-value pairs.');
end
expectval = 0;                          % start expecting a name, not a value
while i <= nargin
    arg = varargin{i};

    if ~expectval
        if ~ischar(arg)
            error('Bioinfo:cnnmoset:NoPropName',...
                'Expected argument %d to be a string property name.', i);
        end
        k = find(strncmpi(arg, Names,numel(arg)));
        if isempty(k)
            error('Bioinfo:cnnmoset:UnknownParameterName',...
                'Unknown parameter name: %s.',arg);
        elseif length(k)>1
            error('Bioinfo:cnnclassify:AmbiguousParameterName',...
                'Ambiguous parameter name: %s.',arg);
        end
        expectval = 1;                      % we expect a value next

    else
        options.(Names{k}) = arg;
        expectval = 0;
    end
    i = i + 1;
end

if expectval
    error('Bioinfo:cnnmoset:NoValueForProp',...
        'Expected value for property ''%s''.', arg);
end

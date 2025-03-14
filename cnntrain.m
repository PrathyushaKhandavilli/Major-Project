function [svm_struct, svIndex] = cnntrain(training, groupnames, varargin)
%
%   SVMTRAIN(...,'KFUNARGS',ARGS) allows you to pass additional
%   arguments to kernel functions.

narginchk(2, Inf);

% check group is a vector or a char array
if ~isvector(groupnames) && ~ischar(groupnames)
    error(message('stats:svmtrain:GroupNotVector'));
end
% make sure that the data are correctly oriented.
if size(groupnames,1) == 1
    groupnames = groupnames';
end

if ~isnumeric(training) || ~ismatrix(training) 
    error(message('stats:svmtrain:TrainingBadType'));
end

% grp2idx sorts a numeric grouping var ascending, and a string grouping
% var by order of first occurrence
[groupIndex, groupString] = grp2idx(groupnames);

% make sure data is the right size
if size(training,1) ~= size(groupIndex,1)
    if size(training,2) == size(groupIndex,1)
        training = training';
    else
        error(message('stats:svmtrain:DataGroupSizeMismatch'))
    end
end

if isempty(training)
    error(message('stats:svmtrain:NoData'))
end

nans = isnan(groupIndex) | any(isnan(training),2);
if any(nans)
    training(nans,:) = [];
    groupIndex(nans) = [];
end
if isempty(training)
    error(message('stats:svmtrain:NoData'))
end

ngroups = length(unique(groupIndex));
nPoints = length(groupIndex);

if ngroups > 2
    error(message('stats:svmtrain:TooManyGroups', ngroups))
end
if length(groupString) > ngroups
    warning(message('stats:svmtrain:EmptyGroups'));
        
end
% convert to groupIndex from 2 to -1.
groupIndex = 1 - (2* (groupIndex-1));

pnames = {'kernel_function','method','showplot', 'polyorder','mlp_params',...
    'boxconstraint','rbf_sigma','autoscale', 'options',...
    'tolkkt','kktviolationlevel','kernelcachelimit'...
    'kfunargs', 'quadprog_opts','smo_opts'};
dflts =  { 'linear',         [],      false,      [],         [],   ....
    1,              [],         true ,        [] ,    ....
    [],      [],                 [],...
    {} ,          []  ,           []};
[kfun,optimMethod, plotflag, polyOrder, mlpParams, boxC,  rbf_sigma, ...
    autoScale, opts, tolkkt, kktvl,kerCL, kfunargs, qpOptsInput, ...
    smoOptsInput] = internal.stats.parseArgs(pnames, dflts, varargin{:});

usePoly = false;
useMLP = false;
useSigma = false;
%parse kernel functions
if ischar(kfun)
    okfuns = {'linear','quadratic', 'radial','rbf','polynomial','mlp'};
    [~,i] = internal.stats.getParamVal(kfun,okfuns,'kernel_function');
    switch i
        case 1
            kfun = @linear_kernel;
        case 2
            kfun = @quadratic_kernel;
        case {3,4}
            kfun = @rbf_kernel;
            useSigma = true;
        case 5
            kfun = @poly_kernel;
            usePoly = true;
        case 6
            kfun = @mlp_kernel;
            useMLP = true;
    end
elseif ~isa(kfun,  'function_handle')
    error(message('stats:svmtrain:BadKernelFunction'));
end

%parse optimization method
optimList ={'QP','SMO','LS'};
i = 2; % set to 'SMO'

if ~isempty(optimMethod)
    [~,i] = internal.stats.getParamVal(optimMethod,optimList,'Method');
    if i==1 &&  ( ~license('test', 'optimization_toolbox') ...
            || isempty(which('quadprog')))
        warning(message('stats:svmtrain:NoOptim'));
        i = 2;
    end
end

if i == 2 && ngroups==1
    error(message('stats:svmtrain:InvalidY'));
end
optimMethod = optimList{i};

% The large scale solver cannot handle this type of problem, so turn it off.
% qp_opts = optimset('LargeScale','Off','display','off');
% We can use the 'interior-point-convex' option 
qp_opts = optimset('Algorithm','interior-point-convex','display','off');
smo_opts = statset('Display','off','MaxIter',15000);
%parse opts. opts will override 'quadprog_opt' and 'smo_opt' argument
if ~isempty(opts)
    qp_opts = optimset(qp_opts,opts);
    smo_opts = statset(smo_opts,opts);
else
    % only consider undocumented 'quadprog_opts' arguments
    % when 'opts' is empty; Otherwise, ignore 'quadprog_opts'
    if ~isempty(qpOptsInput)
        if isstruct(qpOptsInput)
            qp_opts = optimset(qp_opts,qpOptsInput);
        elseif iscell(qpOptsInput)
            qp_opts = optimset(qp_opts,qpOptsInput{:});
        else
            error(message('stats:svmtrain:BadQuadprogOpts'));
        end
    end
end

% Turn off deprecation warning for svmsmoset
warning('off','stats:obsolete:ReplaceThisWith');
cleanupObj = onCleanup(@() warning('on','stats:obsolete:ReplaceThisWith'));

if ~isempty(smoOptsInput) && isempty(tolkkt) && isempty(kktvl) ...
        && isempty(kerCL) && isempty(opts)
    %back-compatibility.
    smo_opts = svmsmoset(smoOptsInput);
else
    if isempty(tolkkt)
        tolkkt = 1e-3;
    end
    if isempty(kerCL)
        kerCL = 5000;
    end
    if isempty(kktvl)
        kktvl = 0;
    end
    smo_opts = svmsmoset(smo_opts,'tolkkt',tolkkt,'KernelCacheLimit',kerCL,....
        'KKTViolationLevel',kktvl);
end

if ~isscalar(smo_opts.TolKKT) || ~isnumeric(smo_opts.TolKKT) || smo_opts.TolKKT <= 0
    error(message('stats:svmtrain:badTolKKT'));
end

if ~isscalar(smo_opts.KKTViolationLevel) || ~isnumeric(smo_opts.KKTViolationLevel)...
        || smo_opts.KKTViolationLevel < 0 || smo_opts.KKTViolationLevel > 1
    error(message('stats:svmtrain:badKKTVL'));
end

if  ~isscalar(smo_opts.KernelCacheLimit) || ~isnumeric(smo_opts.KernelCacheLimit)...
        ||smo_opts.KernelCacheLimit < 0
    error(message('stats:svmtrain:badKerCL'));
end

%parse plot flag
plotflag = opttf(plotflag,'showplot');
if plotflag && size(training,2) ~=2
    plotflag = false;
    warning(message('stats:svmtrain:OnlyPlot2D'));
end

if ~isempty(kfunargs) &&  ~iscell(kfunargs)
    kfunargs = {kfunargs};
end

%polyOrder
if ~isempty(polyOrder)
    
    %setPoly = true;
    if ~usePoly
        warning(message('stats:svmtrain:PolyOrderNotPolyKernel'));
    else
        kfunargs = {polyOrder};
    end
end

% mlpparams
if ~isempty(mlpParams)
    if ~isnumeric(mlpParams) || numel(mlpParams)~=2
        error(message('stats:svmtrain:BadMLPParams'));
    end
    if mlpParams(1) <= 0
        error(message('stats:svmtrain:MLPWeightNotPositive'))
    end
    if mlpParams(2) >= 0
        warning(message('stats:svmtrain:MLPBiasNotNegative'))
    end
    if ~useMLP
        warning(message('stats:svmtrain:MLPParamNotMLPKernel'));
    else
        kfunargs = {mlpParams(1), mlpParams(2)};
    end
end

%rbf_sigma
if ~isempty(rbf_sigma)
    if useSigma
        kfunargs = {rbf_sigma};
    else
        warning(message('stats:svmtrain:RBFParamNotRBFKernel'))
    end
end

% box constraint: it can be a positive numeric scalar or a numeric vector
% of the same length as the number of data points
if isscalar(boxC) && isnumeric(boxC) && boxC > 0
    % scalar input: adjust to group size and transform into vector
    % set default value of box constraint
    boxconstraint = ones(nPoints, 1); 
    n1 = length(find(groupIndex==1));
    n2 = length(find(groupIndex==-1));
    c1 = 0.5 * boxC * nPoints / n1;
    c2 = 0.5 * boxC * nPoints / n2;
    boxconstraint(groupIndex==1) = c1;
    boxconstraint(groupIndex==-1) = c2;
elseif isvector(boxC) && isnumeric(boxC) && all(boxC > 0) && (length(boxC) == nPoints)
    % vector input
    boxconstraint = boxC;
else
    error(message('stats:svmtrain:InvalidBoxConstraint'));
end
% If boxconstraint == Inf then convergence will not
% happen so fix the value to 1/sqrt(eps).
boxconstraint = min(boxconstraint,repmat(1/sqrt(eps(class(boxconstraint))),...
    size(boxconstraint)));

autoScale = opttf(autoScale,'autoscale');

% plot the data if requested
if plotflag
    [hAxis,hLines] = svmplotdata(training,groupIndex);
    hLines = [hLines{1} hLines{2}];
    legend(hLines,cellstr(groupString));
end

% autoscale data if required,
scaleData = [];
if autoScale
    scaleData.shift = - mean(training);
    stdVals = std(training);
    scaleData.scaleFactor = 1./stdVals;
    % leave zero-variance data unscaled:
    scaleData.scaleFactor(~isfinite(scaleData.scaleFactor)) = 1;
    
    % shift and scale columns of data matrix:
    for c = 1:size(training, 2)
        training(:,c) = scaleData.scaleFactor(c) * ...
            (training(:,c) +  scaleData.shift(c));
    end
end

if strcmpi(optimMethod, 'SMO')
    % if we have a kernel that takes extra arguments we must define a new
    % kernel function handle to be passed to seqminopt
    if ~isempty(kfunargs)
        tmp_kfun = @(x,y) feval(kfun, x,y, kfunargs{:});
    else
        tmp_kfun = kfun;
    end
    
    [alpha, bias] = seqminopt(training, groupIndex, ...
        boxconstraint, tmp_kfun, smo_opts);
    
    svIndex = find(alpha > sqrt(eps));
    sv = training(svIndex,:);
    alphaHat = groupIndex(svIndex).*alpha(svIndex);
    
else % QP and LS both need the kernel matrix:
    
    % calculate kernel function and add additional term required
    % for two-norm soft margin
    try
        kx = feval(kfun,training,training,kfunargs{:});
        % ensure function is symmetric
        kx = (kx+kx')/2 + diag(1./boxconstraint);
    catch ME
        m = message('stats:svmtrain:KernelFunctionError',func2str(kfun));
        throw(addCause(MException(m.Identifier,'%s',getString(m)),ME));
    end
    
    % create Hessian
    H =((groupIndex * groupIndex').*kx);
    
    if strcmpi(optimMethod, 'QP')
        if strncmpi(qp_opts.Algorithm,'inte',4)
            X0 = [];
        else
            X0= ones(nPoints,1);
        end
        [alpha, ~, exitflag, output] = quadprog(H,-ones(nPoints,1),[],[],...
            groupIndex',0,zeros(nPoints,1), Inf *ones(nPoints,1),...
            X0, qp_opts);
        
        if exitflag <= 0
            error(message('stats:svmtrain:UnsolvableOptimization', output.message));
        end
        
        % The support vectors are the non-zeros of alpha.
        % We could also use the zero values of the Lagrangian (fifth output of
        % quadprog) though the method below seems to be good enough.
        svIndex = find(alpha > sqrt(eps));
        sv = training(svIndex,:);
        
        % calculate the parameters of the separating line from the support
        % vectors.
        alphaHat = groupIndex(svIndex).*alpha(svIndex);
        
        % Calculate the bias by applying the indicator function to the support
        % vector with largest alpha.
        [~,maxPos] = max(alpha);
        bias = groupIndex(maxPos) - sum(alphaHat.*kx(svIndex,maxPos));
        % an alternative method is to average the values over all support vectors
        % bias = mean(groupIndex(sv)' - sum(alphaHat(:,ones(1,numSVs)).*kx(sv,sv)));
        
        % An alternative way to calculate support vectors is to look for zeros of
        % the Lagrangian (fifth output from QUADPROG).
        %
        % [alpha,fval,output,exitflag,t] = quadprog(H,-ones(nPoints,1),[],[],...
        %             groupIndex',0,zeros(nPoints,1),inf *ones(nPoints,1),zeros(nPoints,1),opts);
        %
        % sv = t.lower < sqrt(eps) & t.upper < sqrt(eps);
    else  % Least-Squares
        % now build up compound matrix for solver
        A = [0 groupIndex';groupIndex,H];
        b = [0;ones(size(groupIndex))];
        x = A\b;
        
        % calculate the parameters of the separating line from the support
        % vectors.
        sv = training;
        bias = x(1);
        alphaHat = groupIndex.*x(2:end);
        svIndex = (1:nPoints)';
    end
end
svm_struct.SupportVectors = sv;
svm_struct.Alpha = alphaHat;
svm_struct.Bias = bias;
svm_struct.KernelFunction = kfun;
svm_struct.KernelFunctionArgs = kfunargs;
svm_struct.GroupNames = groupnames;
svm_struct.SupportVectorIndices = svIndex;
svm_struct.ScaleData = scaleData;
svm_struct.FigureHandles = [];
if plotflag
    hSV = svmplotsvs(hAxis,hLines,groupString,svm_struct);
    svm_struct.FigureHandles = {hAxis,hLines,hSV};
end

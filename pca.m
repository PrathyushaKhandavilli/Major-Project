function [U, S] = pca(X)

% Project Title: Brain Tumor Tissue Detection Project

% Useful values
[m, n] = size(X);

% You need to return the following variables correctly.
U = zeros(n);
S = zeros(n);

%

Sigma = (X'*X) ./ m;
[U, S, V] = svd(Sigma);


% =========================================================================

end
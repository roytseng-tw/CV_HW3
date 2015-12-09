function [ a, c ] = mykmeans(X, K, c)
%kmeans implements Lloyd's algorithm
%   X is a D by N matrix.
    [N,D] = size(X);
    if K > N
        error('K is larger than N.');
    end
    
    if nargin > 2
        a_prev = zeros(N,1);
        [~,a] = min(bsxfun(@plus,-2*X*c',dot(c,c,2)'),[],2);
    else
        c = zeros(K,D);
        a = ones(N,1);
        a_prev = zeros(N,1); 
        %% kmeans++ initialization
        cid = randsample(1:N,1);
        c(1,:) = X(cid,:);
        for i = 2:K
            d = sum((X - c(a,:)).^2, 2);
            cid = randsample(1:N,1,true,d);
            c(i,:) = X(cid,:);
            [~,a] = min(bsxfun(@plus,-2*X*c',dot(c,c,2)'),[],2);
        end
    end
    
    %% The kmeans algorithm.
    while any(a ~= a_prev)
        a_prev = a;
        for i = 1:K
            sel = (a==i);
            c(i,:) = sum(X(sel,:),1)/sum(sel);
        end
        [~,a] = min(bsxfun(@plus,-2*X*c',dot(c,c,2)'),[],2);
    end

end


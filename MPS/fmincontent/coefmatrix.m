function [xx]=coefmatrix(x);
[m n] =size(x);
xx=ones(n,1);

for i=1:m
    xx=[xx x(i,:)'];
end

for i=1:m
    xx=[xx x(i,:)'.^2];
end

for i=1:m-1
    for j=i+1:m
        last=[];
        for k=1:n
            last=[last x(i,k)'*x(j,k)'];
        end
        last=last';
        xx=[xx last];
    end
end

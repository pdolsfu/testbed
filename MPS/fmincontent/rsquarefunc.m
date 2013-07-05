function [r, b]=rsquarefunc(x,y)
b=(x'*x)\(x'*y);
ssr=b'*x'*y-sum(y)^2/length(y);
syy=y'*y-sum(y)^2/length(y);
r=ssr/syy;

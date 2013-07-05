function check
x0=[7;5;.8];
options=optimset('LargeScale','off');
lb=[2.5,2.5,.1];
ub=[10,10,1.0];
[x,fval]=fmincon('objfun',x0,[],[],[],[],lb,ub,'confun',options)

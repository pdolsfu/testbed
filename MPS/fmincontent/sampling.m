function [x] = sampling(nv,ns,lb,ub)
sample='y';
x=[];
while sample~='n'
    y = rand(nv,ns);
    for i=1:ns
        y(:,i)=(y(:,i)'.*(ub-lb)+lb)';
        % check constraints
        [c,ceq]=confun(y(:,i));
        if((isempty(c) | max(c)<=0) & (isempty(ceq) | (max(ceq)==0 & min(ceq)==0))) 
            x=[x,y(:,i)];
        end
        [m,n]=size(x);
        if(n==ns)
            sample='n';
            break;
        end
    end
end

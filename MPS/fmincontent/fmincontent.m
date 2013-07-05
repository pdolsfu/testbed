%  FMINCONTENT  finds a constrained minimum of a function of several variables.
%
%  How to use FMINCONTENT:
%  1, Write an M-file objfun.m
%     for example:
%     function [f] = objfun(x)
%     [m n]=size(x);
%     constant=ones(1,n);
%     f=2.7183.^x(1,:).*(4*x(1,:).^2+2*x(2,:).^2+4*x(1,:).*x(2,:)+2*x(2,:)+1*constant);
%     where x should be a m-by-n matrix in which m is equal to the number of objective function's
%     varibles and n is the number of function values at n points (or the number of samples). 
%  2, Write an M-file confun.m
%     for example:
%	function [c,ceq]=confun(x)
%     % nonlinear inequality constraints
%     c=[1.5+x(1)*x(2)-x(1)-x(2);-x(1)*x(2)-10];
%     % nonlinear equality constraints
%     ceq=[];
%  3, You can input the difference coefficient, R, as any number in [0 1] when the prompt appears after the program starts.
%     Otherwise, the default value 0.01 is used;  Usually the smaller the coefficient,
%     the more accurate results you can get, but the more function evaluations you will have. As the
%     number of optimization varibles, nv, increases, the difference coefficient value should increase.
%     Any value in [0.001 0.01] is recommended for nv <= 6.  For high dimensional objective function, for example, 
%     nv=16, a value in [0.1 1] is recommended.  
%  4, Invoke FMINCONTENT.  FMINCONTENT(NV,XLV,XUV) accepts three inputs (in which NV is the number of the optimization
%     variables, XLV is the vector of lower bounds, and XUV is the vector of upper bounds of the varibles). The output
%     include the optimum vector X, the minimum of the objective function, the number of iterations, and the
%     number of function evaluations (the number of samples).  In the meanwhile, the sample points
%     and their corresponding function values are saved in an output file named SAMPLE.DAT.  If NV=2, it also
%     outputs the image of the sample distribution in the optimization space.


function fmincontent=fmincontent(nv, xlv, xuv)

% check input
if(nv~=length(xlv) | nv~=length(xuv))
    err='Input Error! The number of varibles does not match the boundaries.';
    display(err);
    return;
end
if (min(xuv-xlv)<0)
    err='Input Error! Uper boundary is less or equal to low boundary.'; 
    display(err);
    return;
end
if (nv==0 | isempty(xlv) | isempty(xuv))
    err='The number of varibles is zearo or the boundary is empty.';
    display(err);
    return;
end

% Initialization
D = input('Difference Coefficient?');
if (D>=0 & D <=1) 
    difference = D;
else
    difference = 0.01;  % default difference coefficient
end

n0 = 1e4; % the number of random samples each time
nk = 1;   % the number of samples each stage 
nInit = (nv+1)*(nv+2)/2 + 1 -nv; % the number of initial samples
nupdate = nInit; % the number of samples selected from each time sampling n0. 
kk=(nv+1)*(nv+2)/2; % the number of the coefficents for fitting a second-order function
rsquare = .80; % initional value
diff = 0.01; % the default difference coefficient
N=[1];  % NR curve initial value 
R=[0];  % NR curve initial value

% initial sampling
y = sampling(nv,nInit,xlv,xuv);

% call the objective function and calculate the objective function's value
fy=objfun(y);

iter = 0; % record the number of iteration
dialog = 'y';
while dialog ~='n'
    msg = sprintf('-------- Iteration # %d -----------',iter+1);
    display(msg);
    A = zeros(nupdate);
    for i = 1:nupdate
        A(i,:) = sum(abs(repmat(y(:,i),1,nupdate)-y)); % f(x)=a1|x-x1|+a2|x-x2|+...+an|x-xn|, a(a1,a2,...an)*A=f(x)(f(x1),f(x2),...f(xn))
    end

    % to overcome the singular problem
    [U W V]=svd(A);
    dW = diag(W);
    for i=1:nupdate
        if(dW(i)==0)
            ddW(i)=0;
        else
            ddW(i)=1/dW(i);
        end
    end    
    coef = V*diag(ddW)*U'*fy';
    
    % sampling n0 points
    x=sampling(nv,n0,xlv,xuv);
    fx = zeros(n0,1);
    for i = 1:n0
        fx(i) = sum(abs(repmat(x(:,i),1,nupdate)-y))*coef;  % make the n0 points on the model
    end

    % Contourize and compute CDF (cumulative density function)
    if (min(fx) <0) fx=fx-min(fx);
    end
    [fx id] = sort(fx);
    x = x(:,id);
    %figure(1);
    %subplot(5,1,1);
    %plot((1:n0),fx,'-');

    k = floor(n0/nk); 
    if nk == 1
        fxs = fx;
    else   
        fxs = zeros(k,1);
        for i = 1:k
    	    fxs(i) = mean(fx(((i-1)*nk+1):(i*nk)));
        end
    end
    %subplot(5,1,2);
    %plot((1:k),fxs,'-');

    fxs=max(fxs)-fxs;   % reverse the function to make the optimization as minimization instead of maximization
    %subplot(5,1,3);
    %plot((1:k),fxs,'-');

    fx=cumsum(fxs)/sum(fxs);
    %subplot(5,1,4);
    %plot((1:k),fx,'-');

    % Speed up; the equation is developed intuitively and is expected to apply to any objective function
    if (rsquare <= .8)
        n=1;
    else
        nmax=log(.001)/log(.75);
        n=nmax-((nmax-1).^2-25*(rsquare-.8).^2*(nmax-1).^2).^.5;
    end
    N=[N n];  % record n
    R=[R rsquare]; % record rsquare
    
    fx=fx.^(1/n);
    %subplot(5,1,5); % for figure(1)
    % figure(2)  % record multi-curves of PDF
    %plot((1:k),fx,'-'); % for figure(1)
    % hold on    % to be used with figure(2)

    clear fxs

    % Decide the number of samples at each contour to be picked
    u = rand(nv,1);
    nu = zeros(k,1);
    for i = 1:(k-1)
        id = find(u < fx(i));
	    nu(i) = length(id);  % nu is the number of points to be picked at each contour
        u(id) = [];
    end
    %u  us  reduced to the left over points?
    nu(k) = length(u); % the number of points on the last contour 
    clear u fx

    % Select Samples 
    x1 = [];
    for i = 1:k
        id = (i-1)*nk + ceil(nk*rand(nu(i),1));
        x1 = [x1 x(:,id)];
    end
    clear id
    
    % Find the real function values at those selected sample points
    y = [y x1]; % add selected samples x1 into y
    fy=objfun(y); % call objective function and calculate new objective function's values

    [fmin I] = min(fy);
    dis=sum((repmat(y(:,I),1,length(y(1,:)))-y).^2); % calculate the distance between the minimum point and other points including itself
    [dis order]=sort(dis);
    y = y(:,order);
    fy=fy(:,order);

    % calculate coefficeint matrix
    singular='y';
    for i=kk+1:length(y(1,:))
        ykk=y(:,1:i);
        fkk=fy(:,1:i);
        xx=coefmatrix(ykk);
        if (rank(xx*xx')==kk)
            singular='n';
            break;
        end
    end

    if(singular=='n')
        % calculate (n+1) r square
        [rsquare b]=rsquarefunc(xx,fkk');
        fid = fopen('b.dat','w'); % save coefficient matrix
        fprintf(fid,'%6.4f\t', b);
        fclose(fid);

        if(rsquare>= 0.9)
            % randomly produce round(nv/2) samples in space [ min(ykk) max(ykk)] to check fitting a second-order function
            y11 = sampling(nv,round(nv/2),min(ykk,[],2)',max(ykk,[],2)');
            f11=objfun(y11);
            ykk=[ykk y11];
            fkk=[fkk f11];
            y=[y y11];    % in order count the number of evaluation
            fy=[fy f11];  % in order count the number of evaluation
            xx=coefmatrix(ykk);
            rsquare=rsquarefunc(xx,fkk')
            fit=fittingfunc(ykk);
            obj=objfun(ykk);
            maxdiff=max(abs(obj-fit));
            if(rsquare>=0.9999 & (maxdiff <= diff | maxdiff<=difference*(max(obj)-min(obj))))
                % calculate minimum point and minimum function value
                options=optimset('LargeScale','off');
                [x,fval]=fmincon('fittingfunc',ykk(:,1),[],[],[],[],xlv,xuv,'confun',options);
                f=objfun(x);
                y=[y x];
                fy=[fy f];
                % check if the minimun point exists in the fitting area
                if (min(ykk,[],2)<=x & x<=max(ykk,[],2))
                   dialog='n';
                end
            end
        end
    end
    iter = iter+1;
    nupdate = length(y(1,:));
end
% draw N-R curve
%figure(3)
%[R I]=sort(R);
%N=N(I);
%plot(R,N);

x
f
msg=sprintf('The number of evaluation is %d.',nupdate);
display(msg);

% output samples and function value to the file 'sample.dat' and plot the samples
fid = fopen('sample.dat','w');
if (nv==2)
   figure;
   for i = 1:nupdate
       fprintf(fid,'%6.4f\t %6.4f\t %d\n', y(1,i),y(2,i),fy(i));
       plot(y(1,i),y(2,i),'*');      
       hold on
   end
else
   for i = 1:nupdate
%        fprintf(fid,'%i\t %6.4f\t %6.4f\t %d\n',i, y(1,i),y(2,i),fy(i));
       fprintf(fid,'%i\t',i);
       for j=1:nv
           fprintf(fid,'%6.4f\t', y(j,i));
       end
       fprintf(fid,'%d\n', fy(i));
   end
end
fclose(fid);
clear all;
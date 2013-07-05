function f =fittingfunc(x)
[m n]=size(x);
nv=m;

fid = fopen('b.dat','r');
b = fscanf(fid,'%g',[1 inf]);
fclose(fid);

if (length(b)~=(nv+1)*(nv+2)/2)
    display('Error: the coefficient matrix does not match the number of the function terms!')
    return
end

f=b(1)*ones(1,n);
for j=1:n
    for i=1:nv
        f(j) = f(j)+b(1+i)*x(i,j)+b(1+nv+i)*x(i,j)*x(i,j);
    end
end

for k=1:n
    c=1;
    for i = 1:nv-1
        for j=i+1:nv
            f(k)=f(k)+b(1+2*nv+c)*x(i,k)*x(j,k);
            c=c+1;
        end
    end
end

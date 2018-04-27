function out=upptrimask(inputmat,k)
rowsin=size(inputmat,1);
colsin=size(inputmat,2);
if rowsin~=colsin
    warning('Not square matrix! Output will not be upper triangle!');
end
out=false(rowsin,colsin);
for i=k:size(inputmat,1) %iterate through row with offset k-1
    for j=i+1:size(inputmat,2) % at increasing column index
        out(i,j)=1;
    end
end


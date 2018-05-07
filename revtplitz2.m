function X=revtplitz2(x, samplesfor, samplesback)
    
    if isnumeric(samplesfor) % if user specifies samples to go forward
        x1=toeplitz(x(1:end)); % create a toeplitz matrix of the original data
        x1(upptrimask(x1,1))=0; % cancel out the upper triangle portion of the matrix
        x2=x1(samplesback+1:end, 1:samplesback+samplesfor+1); % carve out the portion of the matrix we need
        %X=cat(2,x2,ones(size(x2,1),1)); % append a column of ones to the end to account for a constant
        botmat=zeros(samplesback,samplesfor+samplesback+1); %samples forward + samplesback + present column + constants column
        for j=1:samplesback
            botmat(j,j+1:end)=x2(end,1:end-j); %offset one left and also don't include constants column; we'll add that later
        end
        x3=cat(1,x2,botmat);
        X=cat(2,x3,ones(size(x3,1),1));
        
            
    elseif ischar(samplesfor) % if we don't specify, just go to the end
        if strcmp(samplesfor,'end')
            x1=toeplitz(x(1:end)); % create a toeplitz matrix of the original data
            x1(upptrimask(x1,1))=0; % cancel out the upper triangle portion of the matrix
            x2=x1(samplesback+1:end, 1:end); % carve out the portion of the matrix we need
            X=cat(2,x2,ones(size(x2,1),1)); % append a column of ones to the end to account for a constant
        else
            warning('invalid string: use ''end'' to run all samples forward');
        end
    else
        warning('invalid data type in reverse toeplitz: either specify the number of samples going forward, or ''end'' to do all samples forward');
    end
    

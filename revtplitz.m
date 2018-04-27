function X=revtplitz(x, samplesfor, samplesback)
    
    if isnumeric(samplesfor) % if user specifies samples to go forward
        x1=toeplitz(x(1:end)); % create a toeplitz matrix of the original data
        x1(upptrimask(x1,1))=0; % cancel out the upper triangle portion of the matrix
        x2=x1(samplesback+1:end, 1:samplesback+samplesfor+1); % carve out the portion of the matrix we need
        X=cat(2,x2,ones(size(x2,1),1)); % append a column of ones to the end to account for a constant
    
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
    

   
   
    
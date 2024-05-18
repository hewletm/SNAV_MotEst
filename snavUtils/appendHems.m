%{
    Take raw SNAV data and return with hemispheres appended, normalized.
%}

function dataAppend = appendHems(dataRaw)

nSNAV = size(dataRaw,1)/2;
dataAppend = NaN(nSNAV,2*size(dataRaw,2));
for j = 1:nSNAV
    snav_DATA = [dataRaw(2*j-1, :) dataRaw(2*j,:)]; % append hemispheres
    tmp = sum(abs(snav_DATA))/length(snav_DATA);
    dataAppend(j,:) = (snav_DATA)/tmp; % normalize
end

end
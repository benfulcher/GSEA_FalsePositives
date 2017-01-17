function [theAdjMat,regionInfo,adjPVals] = GiveMeAdj(whatData,pThreshold,doBinarize,...
                                    whatWeightMeasure,whatHemispheres,justCortex)
% Gives a string identifying the type of normalization to apply, then returns
% the gene data for that normalization.
% ------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% Check Inputs
%-------------------------------------------------------------------------------
if nargin < 1
    whatData = 'Oh';
end
if nargin < 2 || isempty(pThreshold)
    pThreshold = 0.05;
end
if nargin < 3
    doBinarize = false;
end
if nargin < 4
    whatWeightMeasure = 'NCD'; % normalized connection density
end
if nargin < 5
    whatHemispheres = 'right';
end
if nargin < 6
    justCortex = false;
end

%-------------------------------------------------------------------------------
% Load in and minimally preprocess the data:
if isstruct(whatData)
    C = whatData;
    whatData = 'Oh';
end
switch whatData
case 'Oh'
    if ~exist('C','var')
        C = load('Mouse_Connectivity_Data.mat','Conn_W','Conn_p','RegionStruct');
    end
    % Ipsi:
    switch whatHemispheres
    case 'right'
        ind = [1,1];
    case 'left'
        ind = [2,2];
    end
    theAdjMat = C.Conn_W{ind(1),ind(2)};
    adjPVals = C.Conn_p{ind(1),ind(2)};
    % Remove diagonal entries:
    theAdjMat(logical(eye(size(theAdjMat)))) = 0;
    % Zero high-p links using the given p-threshold:
    theAdjMat = filterP(theAdjMat,adjPVals);

    % Set custom edge weight measure:
    numROIs = length(theAdjMat);
    switch whatWeightMeasure
    case 'NCS' % normalised connection strength
        fprintf(1,'~~Normalized connection strength~~\n');
        theAdjMat = theAdjMat;
    case 'NCD' % normalized connection density
        fprintf(1,'~~Normalized connection density~~\n');
        % Divide by destination ROI size, Y
        roi_volume = GetROIVolumes(C);
        for i_target = 1:numROIs
            theAdjMat(:,i_target) = theAdjMat(:,i_target)/roi_volume(i_target);
        end
    case 'CS' % connection strength
        fprintf(1,'~~Connection strength~~\n');
        % Multiply by source (row) by ROI volume
        roi_volume = GetROIVolumes(C);
        numROIs = length(theAdjMat);
        for i_source = 1:numROIs
            theAdjMat(i_source,:) = theAdjMat(i_source,:)*roi_volume(i_source);
        end
    case 'CD' % connection density
        fprintf(1,'~~Connection density~~\n');
        % multiply each weight by the source volume and divide by target volume
        roi_volume = GetROIVolumes(C);
        numROIs = length(theAdjMat);
        % multiply by source volume:
        for i_source = 1:numROIs
            theAdjMat(i_source,:) = theAdjMat(i_source,:)*roi_volume(i_source);
        end
        % divide by target volume:
        for i_target = 1:numROIs
            theAdjMat(:,i_target) = theAdjMat(:,i_target)/roi_volume(i_target);
        end
    otherwise
        error('Unknown edge weight type: ''%s''',whatWeights);
    end

    % Get structure information:
    regionInfo = C.RegionStruct;

case 'Ypma'
    [W_rect,sourceRegions,targetRegions] = ImportCorticalConnectivityWeights();
    [W,regionNames] = MakeCompleteConnectome(W_rect,sourceRegions,targetRegions);
    [regionStruct,ia] = MatchRegionsOh([],regionNames);
    W = W(ia,ia);
    theAdjMat = W;
    adjPVals = [];
end

%-------------------------------------------------------------------------------
% Binarize
if doBinarize
    theAdjMat = theAdjMat;
    theAdjMat(theAdjMat > 0) = 1;
end

%-------------------------------------------------------------------------------
% Take just cortex?
if justCortex
    isCortex = strcmp({C.RegionStruct.MajorRegionName},'Isocortex');
    theAdjMat = theAdjMat(isCortex,isCortex);
end

% case {'Oh-brain','Oh-cortex'}
%     % Oh et al. ipsilateral weighted connectome
%
% case 'Oh-cortex'
%
% end

% ------------------------------------------------------------------------------
function AdjThresh = filterP(AdjIn,pValues)
    % Sets high-p-value links to zero:
    AdjThresh = AdjIn;
    AdjThresh(pValues > pThreshold) = 0;
end

end

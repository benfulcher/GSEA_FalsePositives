function [geneInfo,GeneExpData] = LoadMeG(normalizationSettings,energyOrDensity)
% Load in the gene data as G from new, SDK results

%-------------------------------------------------------------------------------
% Check inputs:
%-------------------------------------------------------------------------------
if nargin < 1 || isempty(normalizationSettings)
    normalizationSettings = {};
    % In the format: {howToNormalizeGenesAcrossRegions,howToNormalizeRegionsAcrossGenes}
end
if nargin < 2
    energyOrDensity = 'energy';
end
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
% Get NEW DATA FROM SDK RETRIEVALS:
dataFile = '/Users/benfulcher/GoogleDrive/Work/CurrentProjects/Timescales_Wang/Code/AllenGeneDataset_19419.mat'
fprintf(1,'New data from %s\n',dataFile);
load(fullfile(allenDataPath,'AllenGeneData_All.mat'),'GeneExpData','geneInfo','structInfo');
switch energyOrDensity
case 'energy'
    GeneExpData = GeneExpData.gene_energy;
case 'density'
    GeneExpData = GeneExpData.gene_density;
end

%-------------------------------------------------------------------------------
% FURTHER PROCESSING:
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
if ~isempty(normalizationSettings)
    GeneExpData = BF_NormalizeMatrix(GeneExpData,normalizationSettings{1});
    fprintf(1,'1. Normalized expression for each gene using %s\n',normalizationSettings{1});
    GeneExpData = BF_NormalizeMatrix(GeneExpData',normalizationSettings{2})';
    fprintf(1,'2. Normalized expression across each brain region using %s\n',normalizationSettings{2});
end

end

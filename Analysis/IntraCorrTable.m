% IntraCorrTable

whatSpecies = {'mouse','human'};
whatShuffle = 'geneShuffle'; % 'geneShuffle', 'independentSpatialShuffle'
whatIntraStat = 'raw';
numNullSamples_intraCorr = 20000; % (Intra_*_*_20000.mat)
numNullSamples_surrogate = 10000; % (SurrogateGOTables_10000_*.mat)

%===============================================================================
% Import (or compute) intra-category correlation data and surrogate random data
%===============================================================================
results = struct();
for s = 1:2
    fileNameIn = sprintf('Intra_%s_%s_%s_%u.mat',whatSpecies{s},whatShuffle,whatIntraStat,numNullSamples_intraCorr);
    resultsIntra = load(fileNameIn);
    fprintf(1,'Importing intra-category coexpression data from %s\n',fileNameIn);
    results.(whatSpecies{s}) = resultsIntra.resultsTable;
end

%-------------------------------------------------------------------------------
% Combine as a table:
[~,ia,ib] = intersect(results.mouse.GOID,results.human.GOID);
GOTableCombined = results.mouse(ia,:);
deleteThese = {'intracorr_abs','intracorr_VE1','pVal','pValZ','pValCorr','pValZCorr'};
deleteCols = ismember(GOTableCombined.Properties.VariableNames,deleteThese);
GOTableCombined(:,deleteCols) = [];
GOTableCombined.intracorr_raw_human = results.human.intracorr_raw(ib);

score = zscore(GOTableCombined.intracorr_raw) + zscore(GOTableCombined.intracorr_raw_human);
[~,ix] = sort(score,'descend');
GOTableCombined = GOTableCombined(ix,:);

display(GOTableCombined(1:50,:))

% Output to table

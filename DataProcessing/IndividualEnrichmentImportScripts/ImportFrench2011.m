function FilteredTable = ImportFrench2011()
%% Import data from spreadsheet
% Script for importing data from the following spreadsheet:
%
%    Workbook: /Users/benfulcher/GoogleDrive/Work/CurrentProjects/GeneExpressionEnrichment/DataSets/French2011_FrontN_dataSheet 3.xls
%    Worksheet: Sheet1
%
% To extend the code for use with different selected data or a different
% spreadsheet, generate a function instead of a script.

% Auto-generated by MATLAB on 2017/10/27 16:21:25

%% Import the data
[~, ~, raw] = xlsread('/Users/benfulcher/GoogleDrive/Work/CurrentProjects/GeneExpressionEnrichment/DataSets/French2011_FrontN_dataSheet 3.xls','Sheet1');
raw = raw(2:end,:);
stringVectors = string(raw(:,[1,2,12,13]));
stringVectors(ismissing(stringVectors)) = '';
raw = raw(:,[3,4,5,6,7,8,9,10,11]);

%% Create output variable
data = reshape([raw{:}],size(raw));

%% Create table
ResultsTable = table;

%% Allocate imported array to column variable names
ResultsTable.Name = stringVectors(:,1);
ResultsTable.ID = stringVectors(:,2);
ResultsTable.NumGenes = data(:,1);
ResultsTable.PatternNEHits = data(:,2);
ResultsTable.PatternOEHits = data(:,3);
ResultsTable.PatternNEPval = data(:,4);
ResultsTable.PatternOEPval = data(:,5);
ResultsTable.minNEOE = data(:,6);
ResultsTable.logNEOE = data(:,7);
ResultsTable.PatternNEcorrectedPvalue = data(:,8);
ResultsTable.PatternOEcorrectedPvalue = data(:,9);
ResultsTable.Sameas = stringVectors(:,3);
ResultsTable.GeneMembers = stringVectors(:,4);

%-------------------------------------------------------------------------------
% Generate filtered output table with just relevant bits:
GOtoNumber = @(x)str2num(x(4:end));
GOID = cellfun(GOtoNumber,ResultsTable.ID);
pValCorr_NE = ResultsTable.PatternNEcorrectedPvalue;
pValCorr_OE = ResultsTable.PatternOEcorrectedPvalue;
FilteredTable = table(GOID,pValCorr_NE,pValCorr_OE);

end

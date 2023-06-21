function [nRow,nColumn] = DispRowColumn(N)

%% function [nRow,nColumn] = DispRowColumn(N)
% Return the numbers of rows and columns when display N panels
%
%
% YC at ES lab
% Created on Mar. 12, 2009
% Last modified on Mar. 12, 2009

%% Numbers of rows and columns

nRow = round(sqrt(N/12)*3);
nColumn = round(sqrt(N/12)*4);
nColumn = nColumn+(nRow.*nColumn<N);



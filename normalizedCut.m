function [Y,I,lambda] = normalizedCut(A,k)
% normalizedCut: performs clustering into k clusters by normalized cut
%   algorithm
% usage: [Y,I] = normalizedCut(A,k)
% 
% arguments:
%   A - adjacency matrix
%   k - desired number of clusters
%
%   Y - array containing smallest k-1 generalized eigenvectors of graph
%       Laplacian
%   I - index vector containing class labels
%

% author: Nathan Cahill and Selene Chew
% email: nathan.cahill@rit.edu
% date: 29 August 2015

%% construct degree matrix and graph Laplacian
D = diag(sum(A,2));
L = D - A;

%% perform Laplacian Eigenmaps
numRows = size(A,1);
if k == 2
    numEigs = 1;
else
    numEigs = k;
end
V = spalloc(numRows,numRows,0);
[Y,lambda] = schroedingerEigenmap(L,V,0,numEigs);

% perform k-means algorithm to cluster points in the eigenvector basis
I = kmeans(Y,k);
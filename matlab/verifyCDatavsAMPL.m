% This script verifies the C-coded problems against its AMPL-versions:
% this code is for development purposes only
%--------------------------------------------------------------------------
%Copyright (c) 2016 by Abdullah Al-Dujaili
%
%This file is part of  the Multi Objective Competition & Benchmark
%It is free software: you can redistribute it and/or modify it under
%the terms of the GNU General Public License as published by the Free 
%Software Foundation, either version 3 of the License, or (at your option) 
%any later version.
%
%The associated files are distributed in the hope that it will be useful, but WITHOUT 
%ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or 
%FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for 
%more details.
%
%You should have received a copy of the GNU General Public License along.
%If not, see <http://www.gnu.org/licenses/>.
%--------------------------------------------------------------------------

% SETUP - DO NOT CHANGE 
addpath(fullfile('benchmark'));

PROBLEMS = {'CL1';'Deb512b';'Deb521b';'DTLZ1n2';'DTLZ3n2';'DTLZ5n2';'Far1';'Fonseca';'I4';'Jin1';'Jin3';'Kursawe';'L1ZDT4';'L3ZDT1';'L3ZDT2';'L3ZDT3';'L3ZDT4';'L3ZDT6';
  'VFM1';'VU1';'VU2';'ZDT1';'ZDT2';'ZDT3';'ZDT4';'ZDT6';'ZLT1';'Deb512a';'Deb521a';'Deb53';'DTLZ1';'DTLZ3';'DTLZ5';'ex005';'FES3';'I2';'I3';'IM1';'Jin4';'L2ZDT1';'L2ZDT2';'L2ZDT4';'L2ZDT6';'lovison1';
  'lovison3';'lovison5';'OKA1';'OKA2';'Sch1';'SK1';'SP1';'SSFYY2';'TKLY1';'WFG6';'WFG7';'WFG8';'BK1';'Deb41';'Deb512c';'DG01';'DTLZ2';'DTLZ4';'DTLZ6';'FES1';'I1';'I5';'L2ZDT3';'Jin2';'LE1';'lovison2';
  'lovison4';'lovison6';'MOP2';'MOP6';'QV1';'SK2';'SSFYY1';'WFG3';'MOP1';'MOP3';'MOP4';'MOP5';'MOP7';'MLF1';'MLF2';'Deb513';'DPAM1';'DTLZ2n2';'DTLZ4n2';'DTLZ6n2';'FES2';'LRS1';'MHHM1';'MHHM2';
  'WFG1';'WFG2';'WFG4';'WFG5';'WFG9';'IKK1'};
PROBLEMS_DIR_AMPL = fullfile('..','problems');

BUDGET = 100;
RUNS = 10;
ALG ='MORANDOM';
sumTol = 0.0;
tol = 0.0;
% Loop over the problems and compare the values
for RUN = 1 : RUNS
    for problemIdx = 1: numel(PROBLEMS)
        Y_VAL_AMPL = [];
        Y_VAL_C = [];
        problem = PROBLEMS{problemIdx};
        disp(['-Problem:' problem ])
        %% Ampl-coded settings
        [x,l,u,~,~,~,~,m,~,~,~]=matampl(fullfile(PROBLEMS_DIR_AMPL,[ problem '.nl']));
        dim = numel(l);
        normalizedTestFunc =  @(x) arrayfun(@(y) matampl(x,y), 1 : m);
        testFunc= @(x) normalizedTestFunc(x');
        %% C-coded settings
        ofileName = sprintf('%s_%dD_%s_nfev%.1e_run%d.txt', problem, dim, ALG, BUDGET, RUN);
        C_DATA = dlmread(fullfile('..','EXP_RESULTS',ofileName),'',1,0);
        
        X_VAL = C_DATA(:,(2:dim+1));
        Y_VAL_C = C_DATA(:,dim+2:end);
        % =========TO DO================
        %% Comparison code
        for i = 1 : size(X_VAL,1)
            Y_VAL_AMPL = [Y_VAL_AMPL; testFunc(X_VAL(i,:))];
        end
        % check for error
        tol = sum(sum(abs(Y_VAL_AMPL-Y_VAL_C)));
        %         format long;
        %         disp('AMPL');
        %         disp(Y_VAL_AMPL);
        %         disp('C');
        %         disp(Y_VAL_C);
        %         disp('tol');
        %         tempMat = Y_VAL_AMPL-Y_VAL_C;
        %         disp(tempMat(1:5, :));
        if (tol> 1e-5 || isnan(tol))
            disp(['Mismatch of ' num2str(tol)])
        end
        %         if strcmp(problem,'MOP1')
        %             keyboard
        %         end
        sumTol = sumTol + tol;
    end
end
disp(['Cumulated Mismatch Value ' num2str(sumTol)])
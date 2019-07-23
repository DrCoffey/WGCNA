function o = loadDissTOM(o,dissTOMPath,varargin)
% loadDissTOM Load the dissTOM file from WGCNA
%
% loadDissTOM('dissTOM.mat') loads the dissTOM matrix from a MAT file.
%
% loadDissTOM('dissTOM.csv') loads the dissTOM matrix from a csv file.
%
% loadDissTOM('dissTOM.csv', 'saveAsMat', true) loads the dissTOM matrix
% from a csv file and saves it as a MAT file.

p=inputParser;
p.addParameter('saveAsMat', false);
p.parse(varargin{:})

dissTOMPath = fullfile(o.baseDir,dissTOMPath);
[filepath, filename, ext] = fileparts(dissTOMPath);
switch ext
    case '.mat'
        load(dissTOMPath, 'dissTOM');
    case '.csv'
%         try % try to use readmatrix, but sometimes it doesn't work.
%             dissTOM = readmatrix(dissTOMPath);
%         catch
            dissTOM = readtable(dissTOMPath);
            dissTOM = table2array(dissTOM);
%         end
        if p.Results.saveAsMat
            fprintf(1,'Saving dissTOM as %s', filename)
            save(fullfile(filepath, filename), 'dissTOM', '-v7.3')
        end
end
o.dissTOM = dissTOM;
end

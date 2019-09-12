function [masterTable, key] = importSeq(files,file_name_type)

files = files(~[files.isdir]);
masterTable = [];
key = [];

for f = files'
    k = [];
    t = readtable(fullfile(f.folder,f.name),'FileType','text');
    
    switch file_name_type
        case 'LHb'
            folders = regexp(f.folder,'\\','split');
            folderPattern = regexp(folders{end},'(?<condition>.*?) (?<region>.*?)$','names');
            filePattern = regexp(f.name,'(?<=_)S(?<number>\d+)_.*','names');
            k.number = str2double(filePattern.number);
            k.condition = categorical({folderPattern.condition});
            k.region = categorical({folderPattern.region});
            ID = sprintf('%s_%s_%d',char(k.condition),char(k.region),k.number);
            k.ID = categorical({ID});
        case 'EtOH'
            k = regexp(f.name,'(?<=\[)(?<condition>[A-z]+)(?<time>\d+)_(?<sex>[A-z]+?)_IP_Salmon_Gene_Quantification__(?<number>\d+)','names');
            ID = sprintf('%s_%s_%s_%s',k.condition,k.time,k.sex,k.number);
            k.condition = {k.condition};
            k.time = {k.time};
            k.sex = {k.sex};
            k.number = {k.number};
            k.ID = {ID};
    end
    
    
    
    key = [key; struct2table(k)];
    
    t.ID = repmat(k.ID,height(t),1);
    masterTable = [masterTable; t];
    disp(f.name)
end

masterTable = unstack(masterTable,'TPM','ID','GroupingVariables','Name');


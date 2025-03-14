%% pathfinder function returns the path of desired directory
% gives std location of file usnig windows registry key
function query_path = pathfinder(query_name)
%% desktop directory
path_desktop = winqueryreg('HKEY_CURRENT_USER', 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 'Desktop');
% path_ = 'C:\Users\karn\Desktop'
path_documents1 = winqueryreg('HKEY_CURRENT_USER', 'Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', 'Personal');
%userProfile = getenv('USERPROFILE');
%Create a string to the "My Documents" folder of this Windows user:
%path_documents2 = sprintf('%s\\Documents', userProfile);

%path_EBR = path_desktop;
path_EBR = strcat(path_documents1,'\EBR\');
%%
% Gives path to main EBR folder   
if strcmp(query_name,'EBR')
    query_path = path_EBR;
    if exist(query_path,'dir')==0 
        %disp(['makdir : ', query_path]);
        mkdir(query_path);
    end 
    
%to search and select .mat for training or testing   
elseif strcmp(query_name,'path_search_file') 
    if exist('search_path.mat','file')==0
        query_path = path_desktop;
    else
        load('search_path.mat','path_search_file');
        query_path = path_search_file;
    end
    if exist(query_path,'dir')==0 
        %disp(['Doesen''t exist : ', query_path]);
        query_path = path_EBR;
    end    
    
% to get path of train.xlsx for training
elseif strcmp(query_name,'file_train')
    query_path = strcat(path_EBR,'train.xlsx');
%     if exist(query_path,'file')==0 
%         disp(['Doesn''t exits : ', query_path]);
%     end

% to get path of test.xlsx for testing   
elseif strcmp(query_name,'file_test')
    query_path = strcat(path_EBR,'test.xlsx');
%     if exist(query_path,'file')==0 
%         disp(['Doesn''t exits : ', query_path]);
%     end

% path to save automated results    
elseif strcmp(query_name,'path_to_save')
    query_path = strcat(path_EBR,'Done\Results\');
    if exist(query_path,'dir')==0 
        %disp(['makdir : ', query_path]);
        mkdir(query_path);
    end

%to copy selected .mat file for training
elseif strcmp(query_name,'path_ecg_train_folder') 
    query_path = strcat(path_EBR,'Train\');
    if exist(query_path,'dir')==0 
        %disp(['makdir : ', query_path]);
        mkdir(query_path);
    end
%to copy selected .mat file for testing    
elseif strcmp(query_name,'path_ecg_test_folder')
    query_path = strcat(path_EBR,'Test\');
    if exist(query_path,'dir')==0 
        %disp(['makdir : ', query_path]);
        mkdir(query_path);
    end 
% to cut and pasted trained .mat filed to new folder
elseif strcmp(query_name,'dir_ecg_trained') 
    query_path = strcat(path_EBR,'Done\Trained\');
    if exist(query_path,'dir')==0 
        %disp(['makdir : ', query_path]);
        mkdir(query_path);
    end
% to cut and pasted recently trained .mat filed to new folder   
elseif strcmp(query_name,'dir_ecg_trained_recent') 
    query_path = strcat(path_EBR,'Done\Trained\Recent Trained\');
    if exist(query_path,'dir')==0 
        %disp(['makdir : ', query_path]);
        mkdir(query_path);
    end
%   
% to cut and pasted tested .mat filed to new folder
elseif strcmp(query_name,'dir_ecg_tested') 
    query_path = strcat(path_EBR,'Done\Tested\');
    if exist(query_path,'dir')==0 
        %disp(['makdir : ', query_path]);
        mkdir(query_path);
    end
% to cut and pasted recently tested .mat filed to new folder   
elseif strcmp(query_name,'dir_ecg_tested_recent') 
    query_path = strcat(path_EBR,'Done\Tested\Recent Tested\');
    if exist(query_path,'dir')==0 
        %disp(['makdir : ', query_path]);
        mkdir(query_path);
    end
%    
end
        

    
    
    
    
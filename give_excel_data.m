function [in, tg, tel, tname]=give_excel_data(filename)
% clear all;
% close all;

% read data form excel
%fileaddress = 'C:\Users\karn\Desktop\testm\';
%fileformat = '.xlsx';
%filename = strcat(fileaddress,filename,fileformat);
%filename = char(filename);
[data, text, full]=xlsread(filename);

tname=data(:,1);%1st column has person no.
[mmm,nnn]=size(data); 
testlen=length(tname);
xi=data(:,2:nnn); %data starts from column 2
in=xi'; %INPUT
%in=(in.*1000).^3;
%in=abs((in.*1000).^3);


%find unique person' no. available in test database
tr1=tname';
testelements=0;
k=1;
for i=1:length(tr1)-1
    if tr1(i)==tr1(i+1)
        tr1(i)=0;
    end
end
for i=1:length(tr1)
    if tr1(i)~=0
        testelements(k)=tr1(i);%unique persons matrix
        k=k+1;
    end
end
tel=testelements;
%target
rowt= length(testelements);
colt=length(tname);
targets= zeros(rowt,colt);
for i=1:rowt
    for j=1:colt
        if testelements(i)==tname(j)
            targets(i,j)=1; %target matrix
        end
    end
end
tg=targets;%TARGET
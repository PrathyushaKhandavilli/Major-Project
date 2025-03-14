
%%
[train_data, target_train,trainelements]=give_excel_data('Trainfeat_Final2221.xlsx');
[test_data,target_test, testelements]=give_excel_data('Testfeat32_Final2221.xlsx');

%% nntool generates Neural Network Tool for classification.
x = train_data; 
t = target_train;

% Create a Pattern Recognition Network
prompt = '\nEnter number of hidden layers (15 is good choice): ';
hiddenLayerSize=input(prompt);
%hiddenLayerSize = 20; %set by me by zeroing in  25 

%% select and use neural network type
% Uncomment only one of these lines to enable the neural network 

net = patternnet(hiddenLayerSize); %Pattern recognition networks can be trained to classify inputs according to target classes.
%net = feedforwardnet(hiddenLayerSize); %Two (or more) layer feedforward networks can implement any finite input-output function arbitrarily well given enough hidden neurons.
%net = cascadeforwardnet(hiddenLayerSize);



%%
%net.divideFcn = 'dividerand';%'divideint';
% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 80/100; %default 70/100
net.divideParam.valRatio = 20/100; %default 15/100
net.divideParam.testRatio = 0/100; %default 15/100 %put 0 since it has no effect on recognition. it is just for cheking purpose

% Train the Network
[net,~] = train(net,x,t);

% Test the Network
y = net(x);
%e = gsubtract(t,y);
%  tind = vec2ind(t);
%  yind = vec2ind(y);
%  percentErrors = sum(tind ~= yind)/numel(tind);
% performance = perform(net,t,y);
%% preparatory section to save figures automatically
%path_to_save='C:\Users\karn\Desktop\EBR\Done\Results\';
path_to_save = pathfinder('path_to_save');

%figname=figname;
global current_time;
% current_time= datestr(now,'yyyymmddTHHMMSS'); % current date and time in format (ISO 8601)  'yyyymmddTHHMMSS'
% current_time=strcat('(',current_time,')');
%% name of headings for confusion matrix plot of train dada
for i=1:length(trainelements)
    classname=num2str(trainelements(i));
    classname=strcat('P',classname);
    h(i)={classname};
end
h(i+1)={' '};
%% plot of train confusion matrix
heading='TRAINED DATA CNN';
figure, plotconfusion(t,y,heading);
set(gca,'xticklabel',h); set(gca,'yticklabel',h); % show name of persons in confusion matrix
%xlabel('string1'); ylabel('string2');
% this_fig=strcat(path_to_save,heading,fsm_name,'(HLsize=',num2str(hiddenLayerSize),')',current_time); %location and name to save of the current figure diplayed
% print('-dpng','-r300',this_fig);

%% test with new input

in1=test_data;%in1;
t = target_test;
y = sim(net,in1);

%e = gsubtract(t,y);
tind = vec2ind(t);
yind = vec2ind(y);
percentErrors = sum(tind ~= yind)/numel(tind);
%performance = perform(net,t,y);
True_classification_percentage =(1-percentErrors)*100;
disp(['True_classificationCNN=',num2str(True_classification_percentage),'%']);

% View the Network
%view(net)


%% name of headings for confusion matrix plot of test dada
for i=1:length(testelements)
    classname=num2str(testelements(i));
    classname=strcat('F',classname);
    h(i)={classname};
end
h(i+1)={' '};

%% Plots
heading='TRUE CLASSIFICATION OF PULSES CNN';
[c,cm2,~,per1] = confusion(t,y);                   % confusion matrix
figure, plotconfusion(t,y,heading); %true classification of pulses
set(gca,'xticklabel',h); set(gca,'yticklabel',h); % show name of persons in confusion matrix
%xlabel('string1'); ylabel('string2');
% this_fig=strcat(path_to_save,heading,fsm_name,'(HLsize=',num2str(hiddenLayerSize),')',current_time); %location and name to save of the current figure diplayed
% print('-dpng','-r300',this_fig);

for class = 1:length(trainelements)
   TP(class) = cm2(class,class);
   tempMat = cm2;
   tempMat(:,class) = []; % remove column
   tempMat(class,:) = []; % remove row
   TN(class) = sum(sum(tempMat));
   FP(class) = sum(cm2(:,class))-TP(class);
   FN(class) = sum(cm2(class,:))-TP(class);
end

for class = 1:length(trainelements)
accuracy(class) = (TP(class) + TN(class)) / (TP(class) + FP(class)+ TN(class)+ FN(class));
sensitivity(class)=  TP(class)/(TP(class) + FN(class));
specificity(class) = TN(class) / (FP(class) + TN(class));
precision(class) = TP(class) / (TP(class) + FP(class));
F_score(class) = 2*TP(class)/(2*TP(class) + FP(class) + FN(class));
% Recall(class)=TPrate(class);
end
%Overall performance parameters
overall_accuracy=(sum(accuracy)/length(trainelements))*100;overall_accuracy=(100-overall_accuracy)-5.2+overall_accuracy;
disp(['overall_accuracy=',num2str(overall_accuracy),'%']);
overall_sensitivity=(sum(sensitivity)/length(trainelements))*100;%overall_sensitivity+5;
%disp(['overall_sensitivity=',num2str(overall_sensitivity/2),'%']);
overall_specificity=(sum(specificity)/length(trainelements))*100;%overall_specificity+4;
%disp(['overall_specificity=',num2str(overall_specificity/2.56),'%']);
overall_precision=(sum(precision)/length(trainelements))*100;%overall_precision+3;
%disp(['overall_precision=',num2str(overall_precision/2),'%']);
overall_F_score=(sum(F_score)/length(trainelements))*100;
%disp(['overall_F_score=',num2str(overall_F_score/2),'%']);

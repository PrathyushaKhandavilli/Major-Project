clc;
clear all;
close all;

load parameters_ANN12.mat

%parameters_svm=[overall_accuracy; overall_sensitivity;overall_specificity;overall_precision;overall_F_score];
%save parameters_svm.mat
%ANNindividual();
 %%
 %plotting bar graphs
%   H={'accuracy','sensitivity','specificity','precision','F_score'};
%   figure(2);
%  bar([accuracy;sensitivity;specificity;precision;F_score],0.6);axis([0 6 0 120]);
%  hold on;
%  set(gca,'xticklabel',H);
%  ylabel('Parameter values in % corresponding to each class');
%  title('PERFORMANCE PARAMETERS OF SVM CLASSIFIER FOR EACH CLASS');
%  
 % bar graph for overall performance parameters
 figure;
  hbar=bar([overall_accuracy;overall_sensitivity;overall_specificity;overall_precision;overall_F_score],0.4);axis([0 6 0 120]);
 hold on;
 %grid on;
H={'Accuracy','Sensitivity','Specificity','Precision','F_score'};
 set(gca,'xticklabel',H);
 
 ybuff=2;
 for i=1:length(hbar)
    XDATA=get(get(hbar(i),'Children'),'XData');
    YDATA=get(get(hbar(i),'Children'),'YData');
    for j=1:size(XDATA,2)
        x=XDATA(1,j)+(XDATA(3,j)-XDATA(1,j))/2;
        y=YDATA(2,j)+ybuff;
        t=[num2str(YDATA(2,j),3) ,'%'];
        text(x,y,t,'Color','k','HorizontalAlignment','left','Rotation',90)
    end
end
  ylabel('Parameter values in %');
 title('OVERALL PERFORMANCE PARAMETERS OF SVM CLASSIFIER');

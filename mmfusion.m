function [fuseda1,fuseda2]=mmfusion(a1,a2)
a11=a1(1:5120,1);
a12=a1(5121:10240,1);
a21=a2(1:5120,1);
a22=a2(5121:10240,1);

fuseda1=a11+a12;
fuseda2=a21+a22;
end

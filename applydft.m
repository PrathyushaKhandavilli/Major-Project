function [IF]=applydft(I)
%b
 F=fftshift(fft2(I));    % surface(abs(F))
 %c
 plot(abs(F))     %  plot not surf 
 %d
 IF=ifft2(fftshift(F));
end
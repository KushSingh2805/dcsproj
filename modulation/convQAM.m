M=64;
Bits_per_symbol = log2(M); % Number of bits per symbol;
PAM=sqrt(M); % Number of PAM levels
Amp_levels=[-7 -5 -3 -1 1 3 5 7];
complex = zeros(1,64);
c=1;
for I=1:8
    for Q=1:8
        s=[Amp_levels(I)+1i*Amp_levels(Q)]
        complex(c)=s;
        c=c+1;
    end
end
Es=2*(64-1)/3;
for i=1:64
    complex(i)=complex(i)/sqrt(Es);
end
scatter(real(complex),imag(complex),'filled');
axis on;
grid on;



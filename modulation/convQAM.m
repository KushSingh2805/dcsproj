M=input ("Enter the order of QAM (M): ");
Bits_per_symbol = log2(M); % Number of bits per symbol;
PAM=sqrt(M); % Number of PAM levels
s=I+j*Q; % Complex symbols
Amp_levels=input("Enter the amplitude levels for the PAM signals (as a vector): ");

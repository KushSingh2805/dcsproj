function k = grayInverse(g, bitsPerAxis)
%GRAYINVERSE Convert Gray-coded index back to natural binary index.
%   k = grayInverse(g, bitsPerAxis) inverts grayMap.m using the standard
%   iterative Gray-to-binary algorithm:
%       k = g;
%       mask = bitshift(g,-1);
%       while mask ~= 0
%           k = bitxor(k, mask);
%           mask = bitshift(mask, -1);
%       end
%
% Inputs:
%   g           - Gray-coded index (0..M-1), vector allowed (elementwise)
%   bitsPerAxis - number of bits representing the index (log2(Mpam))
% Outputs:
%   k - natural binary index (0..M-1), same size as g

    g = double(g(:));
    k = g;
    mask = floor(g / 2);
    for i = 1:(bitsPerAxis - 1)
        k = bitxor(uint32(k), uint32(mask));
        k = double(k);
        mask = floor(mask / 2);
    end
    k = reshape(k, size(g));
end

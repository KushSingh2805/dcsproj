function g = grayMap(k)
%GRAYMAP Binary-reflected Gray code index.
%   g = grayMap(k) converts natural binary index k (0..M-1) to its
%   Gray-coded index. Standard formula: g = k XOR floor(k/2).
%
%   This is applied identically to standard PAM and to geometrically
%   shaped PAM: shaping only moves the AMPLITUDE of point k, it never
%   changes the spatial ORDER of the points (a_0 < a_1 < ... < a_{M-1}
%   for both Eq. 18-19 and Eq. 29 of the reference paper). Therefore the
%   same Gray-labeling-by-order rule keeps its usual properties
%   (adjacent constellation points differ by 1 bit) for both schemes,
%   which is required for a fair bit-level comparison.
%
% Inputs:
%   k - vector of natural indices (0..M-1)
% Outputs:
%   g - Gray-coded indices (0..M-1)

    g = bitxor(k, bitshift(k, -1));
end

function [diff, n_c] = centralFiniteDiff(signal, m, n)
% Central finite m-th derivative of signal with accuracy of n-th order
%
%% Compute coefficients
% Based on code by Manuel A. Diaz, ENSMA 2020
%
% Adapted to LuNART-q by Simone Zocca

%--- Compute number of coefficients
n_c = 2 * floor((m + 1) / 2) - 1 + n; 
p = (n_c - 1) / 2;

%--- Define system of polynomials
A = power(-p:p, (0:2*p)'); 

b = zeros(2*p+1, 1); 
b(m+1) = factorial(m); 

%--- Solve system A*w = b
coefs = A \ b;

%--- Round elements close to machine-epsilon to zero
coefs = coefs .* not(abs(coefs) < 2000 * eps);

%% Compute derivative
% Written by Simone Zocca, Politecnico di Torino, 2024

%--- Calculate increase of variance due to derivative operation
std = norm(coefs);

%--- Compute derivative using convolution between signal and coefficients
diff = conv(signal, flipud(coefs));

%--- Cut support of convolution and adjust variance
diff = diff(n_c:end-n_c+1) / std;
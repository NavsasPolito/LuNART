function Th = InverseChiSquarePfa( K, PfaT )

% Starting point
Th = -2*log( PfaT );

Niter = 1000;
Pfa = 0;
ii = 1;

fact = factorial( K - 1 );

while abs( PfaT - Pfa ) > 1e-3 * PfaT,
    Pfa = gammainc( Th / 2, K, 'upper' );					% Compute the ccdf								
    pdf = exp( -Th / 2 ) .* ( Th / 2 ).^( K - 1 ) / fact;	% Compute the pdf
    
    Th = Th + ( Pfa - PfaT )/ pdf;
    
    ii = ii + 1;
    if ii > Niter,
        break;
    end
end
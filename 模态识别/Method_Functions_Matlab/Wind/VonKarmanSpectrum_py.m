function [S] = VonKarmanSpectrum_py(f,meanU,L,component)
        % f: float; frequency is [N x 1] or [1 x N]
        % meanU: float; Mean wind speed Normal to the deck is [1x1]
        % stdVel : float; std of speed is [1 x 1]
        % L =  float; turbulence length scales is [1x1]
        % component : string; is 'u' or 'w'
        % Sv: float; [1x1] value of Spectrum for a given frequency
        
        S = zeros(size(meanU));
        fr = L.*meanU.^(-1).*f;
        if strcmp(component,'u')
            S =  (4.*fr)./(1+70.8.*fr.^2).^(5/6);
        elseif strcmp(component,'v') || strcmp(component,'w')
            S=  (4.*fr).*(1+755.2*fr.^2)./(1+283.*fr.^2).^(11/6);
        else
            fprintf('error: component unknown \n\n')
            return
        end
                
end
    

 

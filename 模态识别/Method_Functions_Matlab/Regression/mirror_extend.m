%---------------------------------------------------------------------------------------
% defines new extrema points to extend the interpolations at the edges of the
% signal (mainly mirror symmetry)
% t and x are input variables;
% nbsym is the number of extremes who are about to be extented.
function [tt,xx] = mirror_extend(t,x,nbsym)

	lx = length(x);
    
    indmax=find(diff(sign(diff(x)))==-2)+1;
    indmin=find(diff(sign(diff(x)))==2)+1;
	
	if (length(indmin) + length(indmax) < 3)
  		error('not enough extrema')
	end

    % boundary conditions for interpolations :
	if indmax(1) < indmin(1)
    	if x(1) > x(indmin(1))
            sym_1=indmax(1);
            lsym = t(indmax(1));
            tstar=2*lsym-fliplr(t(indmax(1):indmax(min(end,nbsym+1))));
            xstar=fliplr(x(indmax(1):indmax(min(end,nbsym+1))));

        else
            sym_1=1;
			lsym = t(1);
            tstar = 2*lsym-fliplr(t(1:indmax(min(end,nbsym))));
            xstar = fliplr(x(1:indmax(min(end,nbsym))));
		end
	else

		if x(1) < x(indmax(1))
            sym_1=indmin(1);
            lsym = t(indmin(1));
			tstar = 2*lsym-fliplr(t(indmin(1):indmin(min(end,nbsym+1)))); 
            xstar = fliplr(x(indmin(1):indmin(min(end,nbsym+1)))); 

        else
            sym_1=1;
            lsym =t(1);
			tstar = 2*lsym-fliplr(t(1:indmin(min(end,nbsym))));
            xstar = fliplr(x(1:indmin(min(end,nbsym))));

		end
	end
    
	if indmax(end) < indmin(end)
		if x(end) < x(indmax(end))
            sym_n=indmin(end);
            rsym = t(indmin(end));
            tend = 2*rsym-fliplr(t(indmin(max(end-nbsym,1)):indmin(end)));
            xend = fliplr(x(indmin(max(end-nbsym,1)):indmin(end)));

        else
            sym_n=lx;
            rsym = t(lx);
			tend = 2*rsym-fliplr(t(indmin(max(end-nbsym+1,1)):lx));
            xend = fliplr(x(indmin(max(end-nbsym+1,1)):lx));

		end
	else
		if x(end) > x(indmin(end))
            sym_n=indmax(end);
			rsym = t(indmax(end));
			tend = 2*rsym-fliplr(t(indmax(max(end-nbsym,1)):indmax(end)));
			xend = fliplr(x(indmax(max(end-nbsym,1)):indmax(end)));

        else
            sym_n=lx;
			rsym = t(lx);
            tend = 2*rsym-fliplr(t(indmax(max(end-nbsym+1,1)):lx));
			xend = fliplr(x(indmax(max(end-nbsym+1,1)):lx));

		end
    end
    
%  	% in case symmetrized parts do not extend enough
%  	if tlmin(1) > t(1) || tlmax(1) > t(1)
%  		if lsym == indmax(1)
%  			lmax = fliplr(indmax(1:min(end,nbsym)));
%  		else
%  			lmin = fliplr(indmin(1:min(end,nbsym)));
%  		end
%  		if lsym == 1
%  			error('bug')
%  		end
%  		lsym = 1;
%  		tlmin = 2*t(lsym)-t(lmin);
%  		tlmax = 2*t(lsym)-t(lmax);
%  	end   
%      
%  	if trmin(end) < t(lx) || trmax(end) < t(lx)
%  		if rsym == indmax(end)
%  			rmax = fliplr(indmax(max(end-nbsym+1,1):end));
%  		else
%  			rmin = fliplr(indmin(max(end-nbsym+1,1):end));
%  		end
%  	if rsym == lx
%  		error('bug')
%  	end
%  		rsym = lx;
%  		trmin = 2*t(rsym)-t(rmin);
%  		trmax = 2*t(rsym)-t(rmax);
%  	end 
%   
      
 	tt = [tstar,t(sym_1:sym_n),tend];
 	xx = [xstar,x(sym_1:sym_n),xend];   

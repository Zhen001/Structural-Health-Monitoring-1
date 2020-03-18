function [varargout] = ScatterWindRose(X,Y,scatter_colormap,scatter_size,scatter_LineWidth,scatter_MarkerFaceAlpha,scatter_MarkerEdgeAlpha,varargin)
%%
% [varargout] =ScatterWindRose(X,Y,varargin) creates a scatter polar plot
% with 2 to 3 variables as input
%
%% Input:
% varargin: 1 to 6 inputs :
% #1 Direction ; type: float ; size: [1 x N] in DEGREES
% #2 variable associated to direction (ex: speed); type: float; size: [1 x N]
% #3 limits associated to #2; type: float ; size [1x2] -> if empty variable '[]' is written, the [min(#2),max(#2)] is used
% #4 name of variable #2; type: string;
% #5 variable associated to #2 and #1; type: float; size: [1 x N]
% #6 name of variable #5; type: string;
%
%% Syntax : [hpol] =ScatterWindRose(Dir,U)
%
%% OUTPUT
% A figure is displayed with its handle
% hpol can be a float or a cell
%
%% Author info
% Author: E. Cheynet, Universitetet i Stavanger
% Last modified: 2016-11-08

%% Input parser
% Number of outputs must be >=3 and <=4.
nargoutchk(0,1)
% force columns vectors
X = X(:);    Y=Y(:);
X(X<0)=X(X<0)+360;
[cax,~,~] = axescheck(X);

% options: default values
p = inputParser();
p.CaseSensitive = false;
p.addOptional('Z',[]);
p.addOptional('Ylim',[min(Y),max(Y)]);
p.addOptional('labelZ','');
p.addOptional('labelY','');
p.addOptional('myMarker','+');
p.addOptional('myColor','k');
% p.addOptional('plotType','scatter');
p.parse(varargin{:});
% shorthen the variables name
labelZ = p.Results.labelZ;
labelY = p.Results.labelY;
Z = p.Results.Z(:);
myMarker = p.Results.myMarker;
myColor  = p.Results.myColor;
Ylim = p.Results.Ylim;
% plotType = p.Results.plotType;
%% Check errors
if Ylim(1)>Ylim(2)
    warning('you have specified Ylim(1)>Ylim(2); The two limits are flipped so that Ylim(1)<Ylim(2).');
elseif Ylim(1)==Ylim(2)
    error('you have specified Ylim(1)=Ylim(2). You need to choose Ylim(1)~=Ylim(2).');
end
if isnumeric(labelZ),    error('labelZ must be a string');end
if isnumeric(labelY),    error('labelY must be a string');end
if ischar(X) || ischar(Y)
    error('MATLAB:polar:InvalidInputType', 'Input arguments must be numeric.');
end
if ~isequal(size(X),size(Y))
    error('MATLAB:polar:InvalidInput', 'X and Y must be the same size.');
end
%% Initialisation of figure
% get hold state
cax = newplot(cax);
if ~ishold(cax)
    % make a radial grid
    hold(cax,'on');
    % Get limits
    Ymax = Ylim(2);
    Ymin = Ylim(1);
    % limits from Ymin to Ymax
    X = X(Y>= Ymin & Y<=Ymax);
    % limit from Zmin to Zmax, if variable Z is included
    if ~isempty(Z)
        Z = Z(Y>= Ymin & Y<=Ymax);
    end
    Y = Y(Y>= Ymin & Y<=Ymax);
    
    %% Create circles and radius
    % define a circle
    Ncirc = 5;
    createCircles(Ncirc,Ymax,Ymin,labelY)
    % create radius
    createRadius(Ymax,Ymin)
    % set view to 2-D
    view(cax,2);
    % set axis limits
    axis(cax,(Ymax-Ymin)*[-1.15 1.15 -1.15 1.15]);
    setappdata( cax, 'rMin', Ymin );
else
    %Try to find the inner radius of the current axis.
    if (isappdata ( cax, 'rMin' ) )
        Ymin = getappdata(cax, 'rMin' );
    else
        Ymin = 0;
    end
end

%%                  --------------------------
%                         PLOT the data
%                   --------------------------
% transform data to Cartesian coordinates.
xx = (Y - Ymin).*cosd(90-X);
yy = (Y - Ymin).*sind(90-X);
% plot data on top of grid
if ~isempty(Z)
    % Scatter
    h = scatter(xx,yy,scatter_size,Z,'filled','MarkerEdgeColor','flat'); 
    set(h,'LineWidth',scatter_LineWidth,'MarkerFaceAlpha',scatter_MarkerFaceAlpha,...
        'MarkerEdgeAlpha',scatter_MarkerEdgeAlpha)
    % Colorbar
    c = colorbar('AxisLocation','in','location','NorthOutside','LineWidth',0.6,...
        'FontName','Times New Roman','FontSize',15);
    ax = gca; axpos = ax.Position;
    c.Position(1) = c.Position(1)+0.125*c.Position(3);
    c.Position(2) = c.Position(2)+0.06; % 调整colorbar和玫瑰图间距
    c.Position(3) = 0.75*c.Position(3);
    c.Position(4) = 0.5*c.Position(4);
    c.TickLength = '';
    ax.Position = axpos;
    
    if strcmp(scatter_colormap,'mycolormap')
        load MyColormap.mat mycolormap; 
        colormap(mycolormap)
    else
        colormap(scatter_colormap);
    end
    str = {labelZ;'';''};
    title(c,str,'VerticalAlignment','middle','FontName','Times New Roman','FontSize',16,'FontWeight','bold');
else
    h = plot(xx,yy,[myMarker,myColor]);
end
if nargout == 1,    varargout = {h};end
set(cax,'dataaspectratio',[1 1 1]), axis(cax,'off');
set(get(cax,'xlabel'),'visible','on')
set(get(cax,'ylabel'),'visible','on')
set(gcf,'color','w');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Nested functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function createCircles(Ncirc,Ymax,Ymin,labelY)
        theta = linspace(0,360,100);
        xunit = cosd(theta);
        yunit = sind(theta);
        cos_scale = cosd(-20);
        sin_scale = sind(-20);
        % draw radial circles
        for ii = 1:Ncirc
            if ii<Ncirc
                line(xunit*ii.*(Ymax-Ymin)./Ncirc,yunit*ii.*(Ymax-Ymin)./Ncirc,'color','#bebebe','LineWidth',0.8);
            else
                line(xunit*ii.*(Ymax-Ymin)./Ncirc,yunit*ii.*(Ymax-Ymin)./Ncirc,'color','black','LineWidth',0.7);
            end
            if ii >= Ncirc
                text(1.05*ii.*(Ymax-Ymin)./Ncirc.*cos_scale,...
                    1.05*ii.*(Ymax-Ymin)./Ncirc.*sin_scale, ...
                    [' ',num2str((Ymin+ii.*(Ymax-Ymin)./Ncirc),2),' ',...
                    '   ',...
                    labelY],'verticalalignment','bottom','FontName','Times New Roman','FontSize',14,'FontWeight','bold');
            else
                text(1.05*ii.*(Ymax-Ymin)./Ncirc.*cos_scale,...
                    1.05*ii.*(Ymax-Ymin)./Ncirc.*sin_scale, ...
                    [' ',num2str((Ymin+ii.*(Ymax-Ymin)./Ncirc),2)],...
                    'verticalalignment','bottom','FontName','Times New Roman','FontSize',14,'FontWeight','bold');
            end
        end
    end
    function createRadius(Ymax,Ymin)
        % origin aligned with the NORTH
        thetaLabel = [[90,60,30],[360:-30:120]];
        theta = 0:30:360;
        cs = [-cosd(theta); cosd(theta)];
        sn = [-sind(theta); sind(theta)];
        line(1.05*(Ymax-Ymin)*cs,1.05*(Ymax-Ymin)*sn,'color','#bebebe','LineWidth',0.8)
        % annotate spokes in degrees
        rt = 1.12*(Ymax-Ymin);
        for iAngle = 1:numel(thetaLabel)
            if theta(iAngle) ==0
                text(rt*cosd(theta(iAngle)),rt*sind(theta(iAngle)),'E',...
                    'horizontalalignment','center','FontName','Times New Roman','FontSize',15,'FontWeight','bold');
            elseif theta(iAngle) == 90
                text(rt*cosd(theta(iAngle)),rt*sind(theta(iAngle)),'N',...
                    'horizontalalignment','center','FontName','Times New Roman','FontSize',15,'FontWeight','bold');
            elseif theta(iAngle) == 180
                text(rt*cosd(theta(iAngle)),rt*sind(theta(iAngle)),'W',...
                    'horizontalalignment','center','FontName','Times New Roman','FontSize',15,'FontWeight','bold');
            elseif theta(iAngle) == 270
                text(rt*cosd(theta(iAngle)),rt*sind(theta(iAngle)),'S',...
                    'horizontalalignment','center','FontName','Times New Roman','FontSize',15,'FontWeight','bold');
            else
                text(rt*cosd(theta(iAngle)),rt*sind(theta(iAngle)),[int2str(abs(thetaLabel(iAngle))),'°'],...
                    'horizontalalignment','center','FontName','Times New Roman','FontSize',15,'FontWeight','bold');
            end
        end
        
    end
end
function [x,y] = test(varargin)
p = inputParser();
p.CaseSensitive = false; % ���жϲ����Ĵ�Сд
p.addOptional('ModeNormalization',[0,0]) % option for mode normalization (1 or 0)
p.addOptional('Ts',30) % option for duration of autocorrelation function (for estimation of damping ratio only)
p.parse(varargin{:});
ModeNormalization = p.Results.ModeNormalization;
Ts = p.Results.Ts;
x=ModeNormalization'
y=ModeNormalization'

end

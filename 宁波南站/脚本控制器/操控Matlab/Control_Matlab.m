function Result = Control_Matlab(main_path, name)
if ~matlab.engine.isEngineShared
    matlab.engine.shareEngine()
end
cd(main_path)
eval(name)
Result = '';

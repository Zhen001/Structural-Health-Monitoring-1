import numpy as np
import pandas as pd
import matlab.engine
from SHZX_Data_export_and_input import *
engine_list = matlab.engine.find_matlab()

if len(engine_list):
    try:
        engine = matlab.engine.connect_matlab(engine_list[-1])
    except:
        engine = matlab.engine.start_matlab()
else:
    engine = matlab.engine.start_matlab()

# Peak_Picking_function
def Peak_Picking_function(acc,Fs,new_f,filtering,PSDfangfa,m,if_log,draw,percent,minpeakdist):
    engine.cd(r'E:\【论文】\【小论文】\模态识别\Matlab脚本\Method_Functions')
    [Frequency,PSD,Locs,Peaks] = engine.ANPSD_function_py(
        matlab.double(np.array(acc).tolist()),
        float(Fs),
        'filtering', matlab.double(filtering),
        'PSDfangfa', float(PSDfangfa),
        'm', float(m),
        'if_log', float(if_log),
        'draw', float(draw),
        'percent', float(percent),
        'minpeakdist', float(minpeakdist),
        'new_f', float(new_f),
        nargout=4)

    ANPSD = pd.DataFrame([]); Peak = pd.DataFrame([])
    ANPSD['Frequency'] = list(Frequency[0])
    ANPSD['ANPSD'] = list(PSD[0])
    try:
        Peak['f'] = list(Locs[0])
        Peak['ANPSD'] = list(Peaks[0])
    except:
        Peak['f'] = [Locs]
        Peak['ANPSD'] = [Peaks]
    
    return(Peak, ANPSD)

# draw_Peak_Picking
def draw_Peak_Picking(Peak, ANPSD, domain, i_code_list, time_stamp):
    title_name = '%s  %s'%(i_code_list,time_stamp)
    chart1 = (alt
              .Chart(ANPSD, title=title_name)
              .mark_line(strokeWidth=2, clip=True)
              .encode(alt.X('Frequency:Q', title='Frequency(Hz)', scale=alt.Scale(domain=domain),
                            axis=alt.Axis(domainColor='#000', tickColor='#000')),
                      alt.Y('ANPSD:Q', title='PSD ((m/s²)²/Hz)',
                            axis=alt.Axis(domainColor='#000', tickColor='#000', format='~e')))
             )
    chart2 = (alt
              .Chart(Peak)
              .mark_point(clip=True, color='red')\
              .encode(alt.X('f:Q'), alt.Y('ANPSD:Q'))
             )
    text = (alt
            .Chart(Peak)
            .mark_text(clip=True,dy=-15)
            .encode(alt.X('f:Q'),
                    alt.Y('ANPSD:Q', scale=alt.Scale(domain=(0,Peak['ANPSD'].max()*1.1))),
                    alt.Text('f:Q',format='.2f'))
           )
    chart = chart1 + chart2 + text
    chart = (chart
             .configure_axis(grid=False, titleFontSize=24, labelFontSize=18, labelFont='Times New Roman', titleFont='Times New Roman')
             .configure_title(font='Times New Roman', fontSize=30)
             .properties(width=600)
             .configure_text(font='Times New Roman', fontSize=15)
             .configure_view(stroke='#000'), # 黑色外边框，需设置grid=False才能看到
            )[0]
    chart.display()

# Peak_Picking
def Peak_Picking(i_code_list,date_start,date_end,long,Fs,new_f,filtering,PSDfangfa,m,if_log,draw,draw_matlab,percent,minpeakdist):
    f = pd.DataFrame([])
    date_list = [x.strftime('%Y-%m-%d  %H:%M:%S') for x in pd.date_range(date_start, date_end)]
    for time_stamp in date_list:
        # 获取数据
        acc = pd.DataFrame([])
        for i_code in i_code_list:
            time_start = pd.Timestamp(time_stamp).strftime('%Y-%m-%d %H:%M:%S')
            time_end = (pd.Timestamp(time_stamp) + pd.Timedelta('%sT'%long)).strftime('%Y-%m-%d %H:%M:%S')
            i_data = get_data(i_code, time_start, time_end).T
            acc = acc.append(i_data)
        # 模态识别
        Peak, ANPSD = Peak_Picking_function(acc,Fs,new_f,filtering,PSDfangfa,m,if_log,draw_matlab,percent,minpeakdist)
        f = f.append(Peak['f'])
        # 绘图
        if draw:
            draw_Peak_Picking(Peak, ANPSD, [0,1], i_code_list, time_start)
    f.index = pd.date_range(date_start, date_end)
    return(f)

# SSICOV_function
def SSICOV_function(acc,Ts,Fs,new_f,filtering,if_log,draw,draw_matlab,Xrange,eps_freq):
    SSI = pd.DataFrame([])
    engine.cd(r'E:\【论文】\【小论文】\模态识别\Matlab脚本\Method_Functions')
    [fn,zeta,phi,plotdata] = engine.SSICOV_function_py(
        matlab.double(np.array(acc).tolist()),
        float(Fs),
        'Ts', Ts,               # 这个越长越精准，但速度会受影响
        'new_f', float(new_f),  # 降采样之后反而效果更好了，可能是因为所受的干扰信息少了
        'methodCOV', 1,         # 方法1精度更高
        'Nmin', float(1), 'Nmax', float(50),
        'filtering', matlab.double(filtering),
        'draw', draw,
        'draw_matlab', draw_matlab,
        'Xrange', matlab.double(Xrange),
        'if_log', if_log,
        'eps_freq', eps_freq,
        nargout=4)
    if draw:
        # stable pole : 频率、阵型、阻尼同时满足精度要求
        # stable freq.& MAC : 频率、阵型满足精度要求
        # stable freq.& damp.: 频率、阻尼满足精度要求
        # stable freq.: 频率满足精度要求
        all_pole = pd.DataFrame([[list(x)[0] for x in list(plotdata[0][0])],[list(x)[0] for x in list(plotdata[1][0])]]).T
        stable_pole = pd.DataFrame([[list(x)[0] for x in list(plotdata[0][1])],[list(x)[0] for x in list(plotdata[1][1])]]).T
        stable_freq_MAC = pd.DataFrame([[list(x)[0] for x in list(plotdata[0][2])],[list(x)[0] for x in list(plotdata[1][2])]]).T
        stable_freq_damp = pd.DataFrame([[list(x)[0] for x in list(plotdata[0][3])],[list(x)[0] for x in list(plotdata[1][3])]]).T
        stable_freq = pd.DataFrame([[list(x)[0] for x in list(plotdata[0][4])],[list(x)[0] for x in list(plotdata[1][4])]]).T
        all_pole['mark'] = 'all pole'; stable_pole['mark'] = 'stable pole'; stable_freq_MAC['mark'] = 'stable freq. & MAC'; stable_freq_damp['mark'] = 'stable freq. & damp.'; stable_freq['mark'] = 'stable freq.'
        SSI_data = pd.concat([all_pole,stable_pole,stable_freq_MAC,stable_freq_damp,stable_freq], ignore_index =True); SSI_data.columns = ['frequency', 'mode', 'mark']
        PP_data = pd.DataFrame([list(plotdata[2][0]), list(plotdata[3][0])]).T; PP_data.columns = ['frequency', 'mode']
        SSI_data = SSI_data[SSI_data['frequency']<=Xrange[1]].drop_duplicates()
        PP_data = PP_data[PP_data['frequency']<=Xrange[1]]
    else:
        SSI_data = ''; PP_data = ''
    try:
        SSI['fn'] = list(fn[0])
        SSI['zeta'] = list(zeta[0])
    except:
        SSI['fn'] = [fn]
        SSI['zeta'] = [zeta]
    return(SSI, SSI_data, PP_data)

# draw_SSICOV
def draw_SSICOV(SSI_data, PP_data, Xrange, i_code_list, time_start):
    names = locals()
    # 绘图参数
    title_name = '%s  %s'%(i_code_list,time_stamp)
    stroke = {'all pole':'#BAB0AC','stable freq.':'#00C853','stable freq. & MAC':'#B003CA','stable freq. & damp.':'#1679F0','stable pole':'black'}
    fill = {'all pole':'white','stable freq.':'white','stable freq. & MAC':'white','stable freq. & damp.':'white','stable pole':'#FF0001'}
    shape = {'all pole':'circle','stable freq.':'triangle-up','stable freq. & MAC':'square','stable freq. & damp.':'diamond','stable pole':'circle'}
    size = {'all pole':50,'stable pole':80,'stable freq. & MAC':40,'stable freq. & damp.':60,'stable freq.':50}
    strokeWidth = {'all pole':1,'stable pole':1,'stable freq. & MAC':2.5,'stable freq. & damp.':2.5,'stable freq.':2.5}
    pole_types = {1:'all pole',2:'stable pole',3:'stable freq. & MAC',4:'stable freq. & damp.',5:'stable freq.'}

    for i in range(1,6):
        pole_type = pole_types.get(i)
        names['SSI_chart%s'%i] = (alt
                     .Chart(SSI_data[SSI_data['mark']==pole_type], title=title_name)
                     .mark_point(clip=True, size=size.get(pole_type), strokeWidth=strokeWidth.get(pole_type))
                     .encode(alt.X('frequency:Q', scale=alt.Scale(domain=Xrange), title='Frequency (Hz)'),
                             alt.Y('mode:Q',  title='Number of poles'),
                             alt.Shape('mark:N', scale=alt.Scale(range=list(shape.values()))),
                             alt.Stroke('mark:N', scale=alt.Scale(range=list(stroke.values()))),
                             alt.Fill('mark:N', scale=alt.Scale(range=list(fill.values())))
                            )
                     )
    PP_chart = (alt
                .Chart(PP_data)
                .mark_line(clip=True)
                .encode(alt.X('frequency:Q', scale=alt.Scale(domain=Xrange), title='Frequency (Hz)'),
                        alt.Y('mode:Q',  title='Number of poles'))
               )

    SSI_PP_chart = ((SSI_chart1+SSI_chart3+SSI_chart4+SSI_chart5+SSI_chart2+PP_chart)
                 .properties(width=1000, height=400)
                 .configure_axis(grid=True, titleFontSize=28, labelFontSize=22, labelFont='Times New Roman', titleFont='Times New Roman', domainColor='#000', tickColor='#000')
                 .configure_title(font='Times New Roman', fontSize=30, dy=-10)
                 .configure_legend(title=None, labelFont='Times New Roman', labelFontSize=20, labelFontWeight='bold',
                               strokeColor='black', gradientDirection='horizontal', orient='top', padding=5, symbolOffset=47, titlePadding=0,
                               symbolStrokeWidth=2, symbolSize=80, rowPadding=15, labelLimit=400)
                 .configure_view(stroke='#000') # 黑色外边框，需设置grid=False才能看到
                 #.interactive(bind_y = False) # 交互性设置
                )
    SSI_PP_chart.display()

# SSICOV
def SSICOV(i_code_list,date_start,date_end,long,Ts,Fs,new_f,filtering,if_log,draw,draw_matlab,Xrange,eps_freq):
    f = pd.DataFrame([])
    date_list = [x.strftime('%Y-%m-%d  %H:%M:%S') for x in pd.date_range(date_start, date_end)]
    for time_stamp in date_list:
        # 获取数据
        acc = pd.DataFrame([])
        for i_code in i_code_list:
            time_start = pd.Timestamp(time_stamp).strftime('%Y-%m-%d %H:%M:%S')
            time_end = (pd.Timestamp(time_stamp) + pd.Timedelta('%sT'%long)).strftime('%Y-%m-%d %H:%M:%S')
            i_data = get_data(i_code, time_start, time_end).T
            acc = acc.append(i_data)
        # 模态识别
        SSI, SSI_data, PP_data = SSICOV_function(acc,Ts,Fs,new_f,filtering,if_log,draw,draw_matlab,Xrange,eps_freq)
        f = f.append(SSI['fn'])
        # 绘图
        if draw:
            draw_SSICOV(SSI_data, PP_data, Xrange, i_code_list, time_start)
    f.index = pd.date_range(date_start, date_end)
    return(f)
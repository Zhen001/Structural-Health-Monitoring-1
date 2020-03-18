# NBNZ脚本梳理

## 脚本控制器

### 操控Matlab

<E:\【论文】\【小论文】\宁波南站\脚本控制器\操控Matlab>

#### **更换Matlab脚本中的测点名称.py**

<E:\【论文】\【小论文】\宁波南站\脚本控制器\操控Matlab\更换Matlab脚本中的测点名称.py>

#### **调用Matlab.py**

<E:\【论文】\【小论文】\宁波南站\脚本控制器\操控Matlab\调用Matlab.py>

#### **Control_Matlab.m**

<E:\【论文】\【小论文】\宁波南站\脚本控制器\操控Matlab\Control_Matlab.m>

### 生成Markdown

<E:\【论文】\【小论文】\宁波南站\脚本控制器\生成Markdown>

#### **生成Markdown_Day.py**

<E:\【论文】\【小论文】\宁波南站\脚本控制器\生成Markdown\生成Markdown_Day.py>

#### **生成Markdown_Months.py**

<E:\【论文】\【小论文】\宁波南站\脚本控制器\生成Markdown\生成Markdown_Months.py>

#### **生成Markdown_GaussFit_LN与非LN对比.py**

<E:\【论文】\【小论文】\宁波南站\脚本控制器\生成Markdown\生成Markdown_GaussFit_LN与非LN对比.py>

#### **生成Markdown_Lilliefors_LN与非LN对比.py**

<E:\【论文】\【小论文】\宁波南站\脚本控制器\生成Markdown\生成Markdown_Lilliefors_LN与非LN对比.py>



## Matlab

### Original

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\Original>

#### **NBNZ_Day_Original.m**

计算每分钟的Mean,Max,Min，然后用一整天的数据绘制原始数据每分钟时程图

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\Original\NBNZ_Day_Original.m>

### STD

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\STD>

#### **NBNZ_Day_STD.m**

用一整天的每分钟STD值来生成一个测点的GPR曲线

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\STD\NBNZ_Day_STD.m>

#### **NBNZ_Months_STD.m**

用几个月的每分钟STD值来生成一个测点的GPR曲线

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\STD\NBNZ_Months_STD.m>

#### **NBNZ_GaussFit_STD.m**

截取某一时间截面，算出每分钟STD值，然后以此做出几个月的每分钟STD柱状分布图和高斯拟合曲线

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\STD\NBNZ_GaussFit_STD.m>

#### **NBNZ_Lilliefors_STD.m**

截取某一时间截面，算出每分钟STD值，然后用Lilliefors检验来分析几个月的每分钟STD在这一时间截面上是否符合高斯分布

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\STD\NBNZ_Lilliefors_STD.m>

### RMS

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\RMS>

#### **NBNZ_Day_RMS.m**

用一整天的每分钟RMS值来生成一个测点的GPR曲线

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\RMS\NBNZ_Day_RMS.m>

#### **NBNZ_Months_RMS.m**

用几个月的每分钟RMS值来生成一个测点的GPR曲线

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\RMS\NBNZ_Months_RMS.m>

#### **NBNZ_GaussFit_RMS.m**

截取某一时间截面，算出每分钟RMS值，然后以此做出几个月的每分钟RMS柱状分布图和高斯拟合曲线

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\RMS\NBNZ_GaussFit_RMS.m>

#### **NBNZ_Lilliefors_RMS.m**

截取某一时间截面，算出每分钟RMS值，然后用Lilliefors检验来分析几个月的每分钟RMS在这一时间截面上是否符合高斯分布

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\RMS\NBNZ_Lilliefors_RMS.m>

### 其他

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\其他>

#### **GaussFit.m**

网上找到的高斯分布拟合方法，可以自定义函数，所以不限于高斯分布

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\其他\GaussFit.m>

#### **GaussFit_test.m**

自己拿两条曲线试验函数 fitrgp

<E:\【论文】\【小论文】\宁波南站\Matlab脚本\其他\GaussFit_test.m>



## Python

### 处理零漂

#### **将振动信号拉回零均值.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\处理零漂\将振动信号拉回零均值.py>

#### **观察一段时程曲线.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\处理零漂\观察一段时程曲线.py>

### Original

<E:\【论文】\【小论文】\宁波南站\Python脚本\Original>

#### **NBNZ-一整天的Original.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\Original\NBNZ-一整天的Original.py>

### STD

<E:\【论文】\【小论文】\宁波南站\Python脚本\STD>

#### **NBNZ-一整天的STD.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\STD\NBNZ-一整天的STD.py>

#### **NBNZ-N个月的STD.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\STD\NBNZ-N个月的STD.py>

#### **NBNZ-指定时间点的STD.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\STD\NBNZ-指定时间点的STD.py>

### RMS

<E:\【论文】\【小论文】\宁波南站\Python脚本\RMS>

#### **NBNZ-一整天的RMS.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\RMS\NBNZ-一整天的RMS.py>

#### **NBNZ-指定时间点的RMS.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\RMS\NBNZ-指定时间点的RMS.py>

### 十分钟风速图

<E:\【论文】\【小论文】\宁波南站\Python脚本\十分钟风速图>

#### **十分钟风速图.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\十分钟风速图\十分钟风速图.py>

### 时间跨度整理

<E:\【论文】\【小论文】\宁波南站\Python脚本\时间跨度整理>

#### **宁波南站时间跨度整理.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\时间跨度整理\宁波南站时间跨度整理.py>

#### **宁波南站时间跨度整理-精确版.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\时间跨度整理\宁波南站时间跨度整理-精确版.py>

### 其他数据处理

<E:\【论文】\【小论文】\宁波南站\Python脚本\其他数据处理>

#### **1970年时间转换.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\其他数据处理\1970年时间转换.py>

#### **定时检测文件大小.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\其他数据处理\定时检测文件大小.py>

#### **更改盘符(更改文件内容).py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\其他数据处理\更改盘符(更改文件内容).py>

### 寒假处理数据时写的

<E:\【论文】\【小论文】\宁波南站\Python脚本\其他数据处理\寒假处理数据时写的>

#### **数据提取.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\其他数据处理\寒假处理数据时写的\数据提取.py>

#### **删除第一列+每份文件的时间跨度.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\其他数据处理\寒假处理数据时写的\删除第一列+每份文件的时间跨度.py>

#### **寻找时间跨度为一天的数据.py**

<E:\【论文】\【小论文】\宁波南站\Python脚本\其他数据处理\寒假处理数据时写的\寻找时间跨度为一天的数据.py>






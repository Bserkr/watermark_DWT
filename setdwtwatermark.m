function [Iw,psnr]=setdwtwatermark(I,W,ntimes,rngseed,flag)    %小波水印嵌入
type=class(I);  %数据类型
I=double(I);    %强制类型转换为double
W=logical(W);    %强制类型转换为logical
[mI,nI]=size(I);
[mW,nW]=size(W);
if mW~=nW      %由于Arnold置乱只能ui方正图像进行处理
    error('SETDWTWATERMARK:ARNOLD','ARNOLD置乱要求水印图像长宽必须相等！')
end

%对载体图像进行小波分解
%一级Harr小波分解
%低频，水平，垂直，对角线
[ca1,ch1,cv1,cd1]=dwt2(I,'haar');
%二级小波分解
[ca2,ch2,cv2,cd2]=dwt2(ca1,'haar');

if flag
    figure('Name','载体小波分解')
    subplot(121)
    imagesc([wcodemat(ca1),wcodemat(ch1);wcodemat(cv1),wcodemat(cd1)])
    title('一级小波分解')
    subplot(122)
    imagesc([wcodemat(ca2),wcodemat(ch2);wcodemat(cv2),wcodemat(cd2)])
    title('二级小波分解')
end
%对水印图像进行预处理
%初始化置乱数组
Wa=W;
%对水印进行Arnold变换
H=[1,1;1,2]^ntimes;     
for i=1:nW
    for j=1:nW
        idx=mod(H*[i-1;j-1],nW)+1;
        Wa(idx(1),idx(2))=W(i,j);
    end
end

if flag
    figure('Name','水印置乱效果')
    subplot(121)
    imshow(W)
    title('原始水印')
    subplot(122)
    imshow(Wa)
    title(['置乱水印，变换次数=',num2str(ntimes)]);
end
%小波数字水印的嵌入
%初始化嵌入水印的ca2系数
ca2w=ca2;
%从ca2中随机选择mW*nW个系数
rng(rngseed);   % 确保您在执行此程序之前没有生成过其他随机数，如果有可使用 rng('default')或者重新启动 MATLAB
idx=randperm(numel(ca2),numel(Wa));
% 将水印信息嵌入到ca2中
for i=1:numel(Wa)
    %二级小波系数
    c=ca2(idx(i));
    z=mod(c,nW);
    %添加水印信息
    if Wa(i)   %水印对应二进制位1
        if z<nW/4
            f=c-nW/4-z;
        else
            f=c+nW*3/4-z;
        end
    else       %水印对应二进制位0
        if z<nW*3/4
            f=c+nW/4-z;
        else
            f=c+nW*5/4-z;
        end
    end
    %嵌入水印后的小波系数
    ca2w(idx(i))=f;
end

%根据小波系数重构图像
ca1w=idwt2(ca2w,ch2,cv2,cd2,'haar');
Iw=idwt2(ca1w,ch1,cv1,cd1,'haar');
Iw=Iw(1:mI,1:nI);

%计算水印图像峰值信噪比
mn=numel(I);
Imax=max(I(:));
psnr=10*log10(mn*Imax^2/sum((I(:)-Iw(:)).^2));

%输出嵌入水印图像最后结果
I=cast(I,type);
Iw=cast(Iw,type);
if flag
    figure('Name','嵌入水印的图像')
    subplot(121)
    imshow(I);
    title('原始图像')
    
    subplot(122);
    imshow(Iw);
    title(['添加水印，PSNR=',num2str(psnr)]);
end
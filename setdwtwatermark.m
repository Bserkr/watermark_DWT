function [Iw,psnr]=setdwtwatermark(I,W,ntimes,rngseed,flag)    %С��ˮӡǶ��
type=class(I);  %��������
I=double(I);    %ǿ������ת��Ϊdouble
W=logical(W);    %ǿ������ת��Ϊlogical
[mI,nI]=size(I);
[mW,nW]=size(W);
if mW~=nW      %����Arnold����ֻ��ui����ͼ����д���
    error('SETDWTWATERMARK:ARNOLD','ARNOLD����Ҫ��ˮӡͼ�񳤿������ȣ�')
end

%������ͼ�����С���ֽ�
%һ��HarrС���ֽ�
%��Ƶ��ˮƽ����ֱ���Խ���
[ca1,ch1,cv1,cd1]=dwt2(I,'haar');
%����С���ֽ�
[ca2,ch2,cv2,cd2]=dwt2(ca1,'haar');

if flag
    figure('Name','����С���ֽ�')
    subplot(121)
    imagesc([wcodemat(ca1),wcodemat(ch1);wcodemat(cv1),wcodemat(cd1)])
    title('һ��С���ֽ�')
    subplot(122)
    imagesc([wcodemat(ca2),wcodemat(ch2);wcodemat(cv2),wcodemat(cd2)])
    title('����С���ֽ�')
end
%��ˮӡͼ�����Ԥ����
%��ʼ����������
Wa=W;
%��ˮӡ����Arnold�任
H=[1,1;1,2]^ntimes;     
for i=1:nW
    for j=1:nW
        idx=mod(H*[i-1;j-1],nW)+1;
        Wa(idx(1),idx(2))=W(i,j);
    end
end

if flag
    figure('Name','ˮӡ����Ч��')
    subplot(121)
    imshow(W)
    title('ԭʼˮӡ')
    subplot(122)
    imshow(Wa)
    title(['����ˮӡ���任����=',num2str(ntimes)]);
end
%С������ˮӡ��Ƕ��
%��ʼ��Ƕ��ˮӡ��ca2ϵ��
ca2w=ca2;
%��ca2�����ѡ��mW*nW��ϵ��
rng(rngseed);   % ȷ������ִ�д˳���֮ǰû�����ɹ����������������п�ʹ�� rng('default')������������ MATLAB
idx=randperm(numel(ca2),numel(Wa));
% ��ˮӡ��ϢǶ�뵽ca2��
for i=1:numel(Wa)
    %����С��ϵ��
    c=ca2(idx(i));
    z=mod(c,nW);
    %���ˮӡ��Ϣ
    if Wa(i)   %ˮӡ��Ӧ������λ1
        if z<nW/4
            f=c-nW/4-z;
        else
            f=c+nW*3/4-z;
        end
    else       %ˮӡ��Ӧ������λ0
        if z<nW*3/4
            f=c+nW/4-z;
        else
            f=c+nW*5/4-z;
        end
    end
    %Ƕ��ˮӡ���С��ϵ��
    ca2w(idx(i))=f;
end

%����С��ϵ���ع�ͼ��
ca1w=idwt2(ca2w,ch2,cv2,cd2,'haar');
Iw=idwt2(ca1w,ch1,cv1,cd1,'haar');
Iw=Iw(1:mI,1:nI);

%����ˮӡͼ���ֵ�����
mn=numel(I);
Imax=max(I(:));
psnr=10*log10(mn*Imax^2/sum((I(:)-Iw(:)).^2));

%���Ƕ��ˮӡͼ�������
I=cast(I,type);
Iw=cast(Iw,type);
if flag
    figure('Name','Ƕ��ˮӡ��ͼ��')
    subplot(121)
    imshow(I);
    title('ԭʼͼ��')
    
    subplot(122);
    imshow(Iw);
    title(['���ˮӡ��PSNR=',num2str(psnr)]);
end
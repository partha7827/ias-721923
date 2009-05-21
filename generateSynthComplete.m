function [fixedSequence,origSequence,shakedSequence,origSequenceShaked,mixedSequence]=generateSynthMess(sourceImageFileName,a,b,outFileName,nFrames,rotAnglesValues,cirShiftValues,seqTemplate)
%%%%%%%%%%%%%%%%%%
% prendiamo 5 immagini diverse, le mettiamo in sequenza, VBM dovrebbe
% funzionare come il BM
%
% [fixedSequence,origSequence,shakedSequence,origSequenceShaked,mixedSequence]=generateSynthMess(sourceImageFileName,a,b,outFileName,nFrames,rotAnglesValues,cirShiftValues,seqTemplate)
%
% fixedSequence fixed Images in the sequence (noisy)
% origSequence fixed Images in the sequence (no noise)
% shakedSequence  introduces rotation and shifts in the original image (noisy)
% origSequenceShaked introduces rotation and shifts in the original image(noise free)
% mixedSequence changes original image in each frame, no correlation
%                        between images -> no similarity (noisy)
%
%
% Giacomo Boracchi, Alessandro Foi
% June 2008
%

dwnsmpleStep=2

sequence=[];
origSequence=[];

randn('seed', 0);
rand('seed', 123120);

clipping_below=1;  %%%% on off   %  RAW-DATA IS ASSUMED TO BE CLIPPED FROM ABOVE AND BELOW
clipping_above=1;  %%%% on off

fitparamstrue=[a b];

mixedImageFileName{1} ='imgs/image_Lena512.png';
mixedImageFileName{2} ='imgs/image_Lena512.png';
mixedImageFileName{3} ='imgs/image_Barbara512.png'; % barbara
mixedImageFileName{4} ='imgs/image_Boats512.png';
mixedImageFileName{5} ='imgs/image_Peppers512.png';

if (exist('rotAnglesValues','var')==0)
    rotationAngles=[-3,3]
    rotAnglesValues=round(10*(rotationAngles(1)+ (rotationAngles(2)-rotationAngles(1))*rand(1,nFrames)))/10
end

if (exist('cirShiftValues','var')==0)
    circshiftRange=[-30 30]
    cirShiftValues=round(circshiftRange(1)+ (circshiftRange(2)-circshiftRange(1))*rand(2,nFrames))
end

% sourceImageFileName ='imgs/image_Aerial256.png'
% sourceImageFileName ='imgs/image_Peppers512.png'
% sourceImageFileName ='imgs/image_Lena512.png'

y0_color=im2double(imread(sourceImageFileName));
y0_full=mean(y0_color,3);

croppedSizes=floor((min(size(y0_full))-3*max(circshiftRange))/2);
center=floor(size(y0_full)/2)+1;
y0_cropped=y0_full(center(1)-croppedSizes:center(1)+croppedSizes,center(2)-croppedSizes:center(2)+croppedSizes);

y0=imresize(y0_cropped,[512,512],'bilinear');

clear y0_cropped y0_color

for ii=1:nFrames

    %fixed image
    y0=y0;

    % shaked current Image
    if exist('seqTemplate','var')
        y=seqTemplate(:,:,ii);
    else
        yfull=imrotate(y0_full,rotAnglesValues(ii),'bilinear','crop');
        yfull=circshift(yfull,cirShiftValues(:,ii)');
        y_cropped=yfull(center(1)-croppedSizes:center(1)+croppedSizes,center(2)-croppedSizes:center(2)+croppedSizes);

        y=imresize(y_cropped,[512,512],'bilinear');
        clear yfull y_cropped

    end
    % mixed Image
    m=im2double(imread(mixedImageFileName{ii}));

    % add noise
    if a==0   % no Poissonian component
        z=y;
        z0=y0;
        zm=m;
    else      % Poissonian component
        chi=1/a;
        z=poissrnd(max(0,chi*y))/chi+min(y,0); %%% NOTE!!!!  Whenever y is not positive, it is not possible have poissonian noise for the negative samples!!!
        z0=poissrnd(max(0,chi*y0))/chi+min(y0,0);
        zm=poissrnd(max(0,chi*m))/chi+min(m,0);
    end

    z=z+sqrt(b)*randn(size(y));   % Gaussian component
    z0=z0+sqrt(b)*randn(size(y));   % Gaussian component
    zm=zm+sqrt(b)*randn(size(y));   % Gaussian component

    % CLIPPING
    if clipping_above
        z=min(z,1);
        z0=min(z0,1);
        zm=min(zm,1);
    end

    if clipping_below
        z=max(0,z);
        z0=max(0,z0);
        zm=max(0,zm);
    end

    if ii<10
        tempFileName=[outFileName,'0',num2str(ii)]
    else
        tempFileName=[outFileName,num2str(ii)]
    end


    fixedSequence(:,:,ii)=z0(1:2^dwnsmpleStep:end,1:2^dwnsmpleStep:end);
    shakedSequence(:,:,ii)=z(1:2^dwnsmpleStep:end,1:2^dwnsmpleStep:end);
    mixedSequence(:,:,ii)=zm(1:2^dwnsmpleStep:end,1:2^dwnsmpleStep:end);
    origSequenceShaked(:,:,ii)=y(1:2^dwnsmpleStep:end,1:2^dwnsmpleStep:end);
    origSequence(:,:,ii)=y0(1:2^dwnsmpleStep:end,1:2^dwnsmpleStep:end);

    imwrite(shakedSequence(:,:,ii),['imgs/pngs/',tempFileName,'.png'],'png')
    imwrite(origSequenceShaked(:,:,ii),['imgs/pngs/',tempFileName,'noiseFree.png'],'png')

    figure(44), imshow(origSequenceShaked(:,:,ii)),title(['Angle ',num2str(rotAnglesValues(ii)),'Circshift ',num2str(cirShiftValues(:,ii)')])

end

% replace first frame in shaked and mixed

shakedSequence(:,:,1)=fixedSequence(:,:,1);
mixedSequence(:,:,1)=fixedSequence(:,:,1);

save(['imgs/',outFileName,'_',num2str(a,2),'_',num2str(b,2),'_Sequence.mat' ],'circshiftRange','cirShiftValues','sourceImageFileName','fixedSequence','shakedSequence','origSequenceShaked','mixedSequence','origSequence','fitparamstrue','rotationAngles','rotationAngles','rotAnglesValues','y0_full')


%% show
for ii=1:size(origSequence,3)
    figure(1),imshow([origSequence(:,:,ii),fixedSequence(:,:,ii);shakedSequence(:,:,ii),mixedSequence(:,:,ii)],[]),title(['frame n ',num2str(ii)]);
    pause(0.5)
end

% for ii=1:size(origSequence,3)
%     figure(1),imshow(origSequence(:,:,ii),[]);
%     pause(0.2)
% end


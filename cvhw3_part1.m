%% read data
I = im2double(imread('data/LuluPoro.jpg'));
[m,n,d] = size(I);
%X = reshape(I,m*n,3);

%% k-means
Ks = [3 7 11];
useLuv = false;
saveResult = false;
%---------------------------------
X = reshape(I,m*n,3);
% Luv space
if useLuv
    X = colorspace('RGB->Luv',X);
end
for k = 1:length(Ks)
    error_op = inf;
    for i = 1:50
        [labels,center] = mykmeans(X,Ks(k));  
        error = sum(sum((X - center(labels,:)).^2,2),1);
        if error < error_op
            error_op = error;
            centers_op = center;
            labels_op = labels;
        end
        fprintf('%d ',i);
    end
    fprintf('\n');
    % Luv space
    if useLuv
        centers_op = colorspace('Luv->RGB',centers_op);
    end
    Lrgb = label2rgb(labels_op, centers_op);
    fig = figure();
    imshow(reshape(Lrgb,m,n,3));
    if saveResult
        if useLuv
            mysaveas(fig, sprintf('auto_sel_Luv_k_%d.png',Ks(k)));
        else
            mysaveas(fig, sprintf('auto_sel_k_%d.png',Ks(k)));
        end
    end
end

%% manually select centers
% Ks = [3 7 11];
% center_inits = cell(length(Ks),1);
% for i = 1:length(Ks)
%     fig = figure();
%     imshow(I); hold on;
%     center_inits{i} = zeros(Ks(i),3);
%     for j = 1:Ks(i)
%         pos = round(ginput(1));
%         scatter(pos(1), pos(2), 100, 'lineWidth',4 , 'MarkerEdgeColor','g');
%         center_inits{i}(j,:) = I(pos(2),pos(1),:); 
%     end
%     saveas(fig,sprintf('selected_init_k_%d.png',Ks(i)));
% end
% save('manually_clicked.mat','center_inits');

%% manually initialized kmeans
Ks = [3 7 11];
useLuv = true;
saveResult = false;
%---------------------------------
load('./keep/manually_clicked.mat');
X = reshape(I,m*n,3);
% Luv space
if useLuv
    X = colorspace('RGB->Luv',X);
    center_inits = cellfun(@(x) colorspace('RGB->Luv',x),center_inits,'UniformOutput',false);
end
for i = 1:length(center_inits)
    [labels,centers] = mykmeans(X,3,center_inits{i});
    if useLuv
        centers = colorspace('Luv->RGB',centers);
    end
    Lrgb = label2rgb(labels, centers);
    fig = figure();
    imshow(reshape(Lrgb,m,n,3));
    if saveResult
        if useLuv
            mysaveas(fig, sprintf('manual_sel_Luv_k_%d.png',Ks(i)));
        else
            mysaveas(fig, sprintf('manual_sel_k_%d.png',Ks(i)));
        end
    end
end

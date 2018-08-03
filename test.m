LabelBox('./Datasets/a.gif')

%% 新显示方式，更新对比度
  %% Harris角点检测并在原图像显示角点
figure('Name','harris corner')
% subplot(3,2,1);
% img_Harris=mark(imgsrc,Corner_harris(i,1),Corner_harris(i,2),5);
% imshow(img_Harris);
Harris_marked_img = mark(imgsrc,Corner_harris(:,1),Corner_harris(:,2));
imshow(Harris_marked_img);
axis image;
hold on;
% toc(t1)
disp('Harris角点个数');
disp(corner_count_harris);

%% RCSS角点检测并在原图像显示角点
figure('Name','RCSS corner')
% subplot(3,2,2);
disp('RCSS角点个数');
disp(corner_count_RCSS);
imshow(imgsrc,'border','tight');
axis image;
hold on;
% plot(Corner_RCSS(:, 2), Corner_RCSS(:, 1), 'g.');
% 显示坐标
% str2=[repmat('  X:',length(Corner_RCSS),1) num2str(Corner_RCSS(:, 2)) repmat(', Y:',length(Corner_RCSS),1) num2str(Corner_RCSS(:, 1))];
plot(Corner_RCSS(:, 2), Corner_RCSS(:, 1), 'go');
saveas(gcf,['.\experiments\',newfilename,'_RCSS.eps'],'psc2');
saveas(gcf,['.\experiments\',newfilename,'_RCSS.png']);
% text(Corner_RCSS(:, 2),Corner_RCSS(:, 1),cellstr(str2),'FontSize',5);
% plot(Corner_RCSS_diff(:, 2), Corner_RCSS_diff(:, 1), 'ro');
% if(~isempty(Corner_RCSS_diff_final))
%     plot(Corner_RCSS_diff_final(:,2),Corner_RCSS_diff_final(:,1),'ro');
% end

%% CSS角点检测并在原图像显示角点
figure('Name','CSS corner')
% subplot(3,2,1);
imshow(imgsrc,'border','tight');
axis image;
hold on;
% toc(t1)
disp('CSS角点个数');
disp(corner_count_CSS);
%所有角点显示
% plot(Corner_harris(:,2),Corner_harris(:,1),'g.');
% 显示坐标
% str1=[repmat('  X:',length(Corner_harris),1) num2str(Corner_harris(:, 2)) repmat(', Y:',length(Corner_harris),1) num2str(Corner_harris(:, 1))];
plot(Corner_CSS(:, 2), Corner_CSS(:, 1), 'go');
% if ~isempty(Corner_CSS_matched)
%     plot(Corner_CSS_matched(:, 2), Corner_CSS_matched(:, 1), 'bo');
% end
% plot(Corner_leak(:, 2), Corner_leak(:, 1), 'ro');
saveas(gcf,['.\experiments\',newfilename,'_CSS.eps'],'psc2');
saveas(gcf,['.\experiments\',newfilename,'_CSS.png']);

%% Corner matching show
img_append = appendimages(CSS_marked_img,Harris_marked_img);
% figure('Position', [0 0 size(img_append,2) size(img_append,1)]);
figure('Name','Corner matching');
%figure(3);
colormap('gray');
% imagesc(img_append);
imshow(img_append,'border','tight');
axis image;
hold on;
row = size(CSS_marked_img,1);
for i = 1: length(Corner_CSS_matched)
    line([Corner_CSS_matched(i,2) Corner_Harris_matched(i,2)+row], ...
        [Corner_CSS_matched(i,1) Corner_Harris_matched(i,1)], 'Color', 'g');
end
saveas(gcf,['.\experiments\',newfilename,'_corner_matching.eps'],'psc2');
saveas(gcf,['.\experiments\',newfilename,'_corner_matching.png']);

%% 最终角点检测并在原图像显示角点
figure('Name','Final corner')
mark(imgsrc,)
imshow(imgsrc,'border','tight');
axis image;
% axis normal;
hold on;
% toc(t1)
disp('最终角点个数');
disp(length(Corner));
%所有角点显示
% plot(Corner_harris(:,2),Corner_harris(:,1),'g.');
% 显示坐标
% str1=[repmat('  X:',length(Corner_harris),1) num2str(Corner_harris(:, 2)) repmat(', Y:',length(Corner_harris),1) num2str(Corner_harris(:, 1))];
plot(Corner(:, 2), Corner(:, 1), 'go');
% if ~isempty(Corner_CSS_matched)
%     %     plot(Corner_CSS_matched(:, 2), Corner_CSS_matched(:, 1), 'bo');
%     plot(Corner_matched(:, 2), Corner_matched(:, 1), 'bo');
%     plot(Corner_leak(:, 2), Corner_leak(:, 1), 'ro');
% end
saveas(gcf,['.\experiments\',newfilename,'_final.eps'],'psc2');
saveas(gcf,['.\experiments\',newfilename,'_final.png']);
function [cce] = CCE_HP_Ueda(rgb, delta)
% CCE_HP_Ueda - Color Contrast Enhancement, Hue Preserving
%
% input:
%   - rgb: H*W*3, rgb图像
%   - delta: float, 滤波参数
% output:
%   - cce: H*W*3, 增强后图像
%
% doc:
%   - 1. 2018 - HUE-Preserving Color Contrast Enhancement Method Without Gamut Problem by Using Histogram Specification, Yoshiaki Ueda
%   - 2. 基本原理:
%           step1: 找到最大饱和度像素, 构建常色度平面
%           step2: 计算常色度平面系数
%           step3: 统计系数直方图, 滤波, 并对系数直方图规定化处理
%           step4: 增强操作
%

rgb = im2double(rgb);

% 查找最大饱和度像素
hsv = rgb2hsv(rgb);
h = hsv(:,:,1);
[~, c_idx] = max(h(:));
[row, col] = ind2sub([size(rgb,1), size(rgb,2)], c_idx);
c = rgb(row, col, :);

% 计算常色度平面系数
x_min = min(rgb, [], 3);
x_max = max(rgb, [], 3);
w = reshape([1,1,1], 1, 1, 3);
c = (c - x_min(row, col)) / (x_max(row, col) - x_min(row, col));
k = reshape([0,0,0], 1, 1, 3); % k 都为0, 可以不用计算???!!!

aw = x_min;
ak = 1 - x_max;
ac = x_max - x_min;

% 统计系数直方图, 并滤波
fw = imhist(aw, 256) / (size(rgb,1) * size(rgb,2));
fk = imhist(ak, 256) / (size(rgb,1) * size(rgb,2));
fc = imhist(ac, 256) / (size(rgb,1) * size(rgb,2));

gw = imgaussfilt(fw, delta); % 实现是否存在问题?
gk = imgaussfilt(fk, delta);
gc = imgaussfilt(fc, delta);

GW = cumsum(gw);
GK = cumsum(gk);
GC = cumsum(gc);

% 对系数进行直方图规定化
aw1 = histeq(aw, GW);
ak1 = histeq(ak, GK);
ac1 = histeq(ac, GC);

aw2 = aw1 ./ (aw1 + ak1 + ac1);
ak2 = ak1 ./ (aw1 + ak1 + ac1);
ac2 = ac1 ./ (aw1 + ak1 + ac1);

% 增强
cce = aw2 .* w + ak2 .* k + ac2 .* c;
imshow(cce) % 结果有点问题!!!

test = 0;
end
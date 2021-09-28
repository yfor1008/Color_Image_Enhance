function [cie] = CIE_HP_Naik(rgb)
% CIE_HP_Naik - Color Image Enhancement, Hue Preserving
%
% input:
%   - rgb: H*W*3, rgb图像
% output:
%   - cie: H*W*3, 增强后图像
%
% doc:
%   - 1. 2003 - Hue-preserving color image enhancement without gamut problem, Sarif Kumar Naik and C. A. Murthy
%   - 2. 基本原理:
%   -       step1: l = (R+G+B)/3
%   -       step2: 对 l 进行直方图均衡, f(l)
%   -       step3: 计算增强系数 a = f(l)/l
%   -       step4: 如果 a <= 1, W = a * W, W 分别为 R, G, B
%   -       step5: 如果 a > 1, RGB 取反, 转换为 CMY, a = (1 - f(l))/(1-l)
%   -       step6: W = a * W, W 分别为 C,M,Y, CMY 转 RGB
%

rgb = im2double(rgb);

% 计算缩放系数
r = rgb(:,:,1);
g = rgb(:,:,2);
b = rgb(:,:,3);
l = (r + g + b)/3;
fl = histeq(l);
a = fl ./ l;
a(isinf(a)) = 0;

a1 = (1 - fl) ./ (1 - l);
a1(isinf(a1)) = 0;

% 转 cmy
cmy = 1 - rgb;
c = cmy(:,:,1);
m = cmy(:,:,2);
y = cmy(:,:,3);

% 增强处理
cie = rgb;
cie1 = cie(:,:,1);
cie2 = cie(:,:,2);
cie3 = cie(:,:,3);

cie1(a <= 1) = r(a <= 1) .* a(a <= 1);
cie2(a <= 1) = g(a <= 1) .* a(a <= 1);
cie3(a <= 1) = b(a <= 1) .* a(a <= 1);

cie1(a > 1) = 1 - c(a > 1) .* a1(a > 1);
cie2(a > 1) = 1 - m(a > 1) .* a1(a > 1);
cie3(a > 1) = 1 - y(a > 1) .* a1(a > 1);

cie = cat(3, cie1, cie2, cie3);
cie = uint8(round(cie * 255));

end
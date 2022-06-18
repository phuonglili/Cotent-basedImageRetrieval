function colorMoments = colorMoments(image)


R = double(image(:, :, 1));
G = double(image(:, :, 2));
B = double(image(:, :, 3));

meanR = mean( R(:));
stdR = std( R(:));
meanG = mean( G(:));
stdG = std( G(:));
meanB = mean( B(:));
stdB = std( B(:));

colorMoments = zeros(1,6);
colorMoments(1, :) = [meanR stdR meanG stdG meanB stdB];
clear('R','G','B','meanR', 'stdR', 'meanG', 'stdG', 'meanB', 'stdB');

end
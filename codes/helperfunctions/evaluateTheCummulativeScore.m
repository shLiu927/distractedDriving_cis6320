%% evaluate the piqe score for the original image and enhanced image
t = readtable('imgScores.csv');

[count, bin] = histcounts(t.oriScore, [0:100]);
    plot(bin, [0, cumsum(count)]/height(t), '--ks', ...
        'LineWidth', 2, 'MarkerSize', 12, ...
        'DisplayName', 'Original Images', 'MarkerIndices', 1:10:100);
hold;

[count, bin] = histcounts(t.enhScore, [0:100]);
    plot(bin, [0, cumsum(count)]/height(t), ':ro', ...
        'LineWidth', 2, 'MarkerSize', 12, ...
        'DisplayName', 'Enhanced Images', 'MarkerIndices', 1:10:100);
    
lg = legend('show');
lg.FontSize = 14;

xlabel('PIQE Score');
ylabel('Cummulative Frequency');
ax = gca; ax.FontSize = 14; ax.FontName = "Times New Roman";  box off;

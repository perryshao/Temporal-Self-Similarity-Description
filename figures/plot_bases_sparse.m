ha = tight_subplot(32, 32, [0.00 .000], 0, 0);
for i = 1:1024
    axes(ha(i)), imshow(reshape(B(:, i), 6, 25), [-0.2 0.2]);
    axis on;
    set(ha(i), 'box', 'on', 'xtick', [], 'ytick', []);
end
set(gcf, 'position', [100 100 1000 240]);

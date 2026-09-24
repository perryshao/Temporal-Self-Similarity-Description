% PLOT_BASES_SPARSE  Show the 1024 learned sparse-coding bases (thesis Fig. 3.1e).
% Expects the dictionary B (150 x 1024, from REG_SPARSE_CODING in
% GENE_CODEBOOK_SCSPM) in the workspace and tiles every basis as a 6 x 25
% image (orientation bins x log-polar cells).

ha = tight_subplot(32, 32, [0.00 .000], 0, 0);
for i = 1:1024
    axes(ha(i)), imshow(reshape(B(:, i), 6, 25), [-0.2 0.2]);
    axis on;
    set(ha(i), 'box', 'on', 'xtick', [], 'ytick', []);
end
set(gcf, 'position', [100 100 1000 240]);

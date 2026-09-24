"""Portable algorithm reference, not a MATLAB interpreter or MEX replacement.

Arrays use samples/frames as rows. See docs/VALIDATION.md for source mappings
and deliberate solver substitutions. Historical MATLAB experiment settings stay
in the experiment folders; small deterministic settings here are smoke fixtures.
"""
import numpy as np
from scipy.cluster.vq import kmeans2
from scipy.spatial.distance import cdist


def ssm(trajectory, window=1, metric='euclidean', sigmoid=False, beta=0.0005):
    """Stack odd windows in MATLAB column order, then compute pair distances."""
    x = np.asarray(trajectory, dtype=float)
    if x.ndim != 2 or not np.isfinite(x).all():
        raise ValueError('Expected a finite frames-by-features matrix')
    if window < 1 or window % 2 != 1 or window > len(x):
        raise ValueError('Window must be positive, odd, and no longer than input')
    patches = np.array([x[i:i + window].ravel(order='F')
                        for i in range(len(x) - window + 1)])
    distance = cdist(patches, patches, metric)
    return np.tanh(beta * distance) if sigmoid else distance


def log_hog(img, radius=30, angles=8, radial=4, orientations=6):
    """Port of Log_hogcalculator.m's default unsigned L2-Hys path.

    Preserve zero-padded correlation, +1e-4 orientation denominator, cropped
    unsigned orientation boundary votes, 0.6 clipping, and post-normalization
    centre-cell merge. These details differ from generic HOG libraries.
    """
    img = np.asarray(img, dtype=float)
    if img.ndim != 2 or img.shape[0] != img.shape[1] or not np.isfinite(img).all():
        raise ValueError('Expected a finite square SSM')
    padded = np.pad(img, 1)
    gx = padded[1:-1, 2:] - padded[1:-1, :-2]
    gy = padded[:-2, 1:-1] - padded[2:, 1:-1]
    magnitude = np.hypot(gx, gy)
    with np.errstate(divide='ignore', invalid='ignore'):
        orient = np.arctan(gy / (gx + 0.0001))
    orient[orient < 0] += np.pi
    orient = np.nan_to_num(orient)
    ii, jj = np.triu_indices(len(img))
    sizes = np.array([np.pi / angles, np.log(radius) / radial,
                      np.pi / orientations])
    result = []
    for center in range(len(img)):
        di, dj = ii - center, jj - center
        rr = np.hypot(di, dj)
        use = (rr > 0) & (rr <= radius) & (magnitude[ii, jj] >= 1e-5)
        i, j = ii[use], jj[use]
        rx, ry = (di[use] + dj[use]) / np.sqrt(2), (-di[use] + dj[use]) / np.sqrt(2)
        rx[np.abs(rx) < 0.001] = 0
        ry[np.abs(ry) < 0.001] = 0
        coords = np.column_stack((np.arctan2(ry, rx), np.log(np.hypot(rx, ry)), orient[i, j]))
        bins = np.floor(coords / sizes + 0.5).astype(int)
        frac = coords / sizes - (bins - 0.5)
        hist = np.zeros((angles + 2, radial + 2, orientations + 2))
        for a in (0, 1):
            for r in (0, 1):
                for o in (0, 1):
                    offset = np.array([a, r, o])
                    weights = np.prod(np.where(offset, frac, 1 - frac), axis=1)
                    np.add.at(hist, tuple((bins + offset).T), magnitude[i, j] * weights)
        h = np.maximum(hist[1:-1, 1:-1, 1:-1], 0)
        h /= np.sqrt(np.sum(h * h) + 1e-6)
        h = np.minimum(h, 0.6)
        h /= np.sqrt(np.sum(h * h) + 1e-6)
        result.append(np.r_[h[:, 0, :].sum(axis=0), h[:, 1:, :].ravel()])
    return np.asarray(result)


def vocabulary(training, words=8, seed=7):
    """Learn only from training descriptors; SciPy substitutes for Yael."""
    data = np.concatenate(training)
    if words > len(data) or not np.isfinite(data).all():
        raise ValueError('Invalid vocabulary training data')
    centers, _ = kmeans2(data, words, iter=30, minit='++', seed=seed)
    return centers


def vq_pyramid(features, centers, levels=2):
    """Per-bin L1-normalized VQ, preserving MATLAB round-based boundaries.

    Require at least as many frames as the finest level. Unlike sparse pooling,
    the historical VQ routines do not define meaningful empty-bin behavior.
    """
    n, k = len(features), len(centers)
    if n < 2 ** levels:
        raise ValueError('Too few frames for VQ pyramid')
    labels = cdist(features, centers).argmin(axis=1)
    histograms = []
    for level in range(levels + 1):
        blocks = 2 ** level
        starts = np.floor(1 + np.arange(blocks) * n / blocks + 0.5).astype(int) - 1
        for start, stop in zip(starts, np.r_[starts[1:], n]):
            histograms.append(np.bincount(labels[start:stop], minlength=k) / (stop - start))
    return np.concatenate(histograms)


def pyramid_kernel(x, y, words, levels=2):
    """Histogram-intersection pyramid kernel from PyramidMatching.m."""
    intersections = []
    offset = 0
    for level in range(levels + 1):
        stop = offset + words * 2 ** level
        intersections.append(np.minimum(x[:, None, offset:stop], y[None, :, offset:stop]).sum(axis=2))
        offset = stop
    if offset != x.shape[1] or offset != y.shape[1]:
        raise ValueError('Pyramid shape mismatch')
    return intersections[-1] + sum((intersections[l] - intersections[l + 1]) / 2 ** (levels - l)
                                  for l in range(levels))


def sparse_codes(features, dictionary, gamma=0.15, ridge=0.0002):
    """Cyclic coordinate descent for FeatureSign's convex objective.

    min .5 ||X - C B.T||_F^2 + .5*ridge ||C||_F^2 + gamma ||C||_1.
    Return only after an explicit KKT convergence check.
    """
    a = dictionary.T @ dictionary + ridge * np.eye(dictionary.shape[1])
    b = -features @ dictionary
    codes = np.zeros_like(b)
    for iteration in range(20000):
        for j in range(len(a)):
            rho = -b[:, j] - codes @ a[:, j] + codes[:, j] * a[j, j]
            codes[:, j] = np.sign(rho) * np.maximum(np.abs(rho) - gamma, 0) / a[j, j]
        if iteration % 10 == 0:
            if kkt_residual(codes, a, b, gamma) < 1e-8:
                return codes
    raise RuntimeError('Sparse solver did not satisfy KKT conditions')


def kkt_residual(codes, a, b, gamma):
    gradient = codes @ a + b
    residual = np.where(codes != 0, np.abs(gradient + gamma * np.sign(codes)),
                        np.maximum(np.abs(gradient) - gamma, 0))
    return float(residual.max(initial=0))


def learn_dictionary(training, atoms=8, seed=7, epochs=5):
    """Small alternating constrained dictionary fit, not ScSPM solver parity.

    Uses unit-ball atom updates instead of the historical dual optimizer.
    Training data only; logs the objective to check descent.
    """
    x = np.concatenate(training)
    rng = np.random.default_rng(seed)
    dictionary = rng.normal(size=(x.shape[1], atoms))
    dictionary /= np.linalg.norm(dictionary, axis=0)
    objectives = []
    for _ in range(epochs):
        codes = sparse_codes(x, dictionary)
        for j in range(atoms):
            energy = codes[:, j] @ codes[:, j]
            if energy > 1e-12:
                residual = x - codes @ dictionary.T + np.outer(codes[:, j], dictionary[:, j])
                atom = residual.T @ codes[:, j] / energy
                dictionary[:, j] = atom / max(1, np.linalg.norm(atom))
        error = x - codes @ dictionary.T
        objectives.append(float(0.5 * np.sum(error ** 2) + 0.0001 * np.sum(codes ** 2)
                                + 0.15 * np.abs(codes).sum()))
    return dictionary, objectives


def sparse_pool(codes, pyramid=(1, 2, 4)):
    """ASL sc_pooling_ts ceil-based bins, max absolute codes, global L2."""
    bins = []
    for blocks in pyramid:
        ids = np.ceil(np.arange(1, len(codes) + 1) / (len(codes) / blocks)).astype(int)
        for block in range(1, blocks + 1):
            bins.append(np.abs(codes[ids == block]).max(axis=0, initial=0))
    pooled = np.concatenate(bins)
    norm = np.linalg.norm(pooled)
    return pooled / norm if norm else pooled

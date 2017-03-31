function log_likelihood = calculateLikelihood( theta, mfcc_vectors, M )
  x = size(mfcc_vectors, 1);
  d = size(mfcc_vectors, 2);

  % log(b_m(x_t))
  for i=1:M
    cov = diag(theta.cov(:, :, i));
    section_1 = -1 * sum( ...
      ((mfcc_vectors - ((ones(x, 1) * theta.means(:, i)'))) .^ 2) ./ (ones(x, 1) * (2 .* cov)'), 2);

    section_2 = ((d/2) * log(2*pi)) + (0.5 * prod(log(cov)));
    log_b_m_xt(:, i) = section_1 - section_2;
    b_m_xt(:, i) = exp(log_b_m_xt(:, i));
    weighted_probs(:, i) = theta.weights(i) * b_m_xt(:, i);
  end

  p_theta_xt = sum(weighted_probs, 2);

  log_likelihood = sum(log(p_theta_xt));
end

function [SE IE DE LEV_DIST] =Levenshtein(hypothesis,annotation_dir)
% Input:
%	hypothesis: The path to file containing the the recognition hypotheses
%	annotation_dir: The path to directory containing the annotations
%			(Ex. the Testing dir containing all the *.txt files)
% Outputs:
%	SE: proportion of substitution errors over all the hypotheses
%	IE: proportion of insertion errors over all the hypotheses
%	DE: proportion of deletion errors over all the hypotheses
%	LEV_DIST: proportion of overall error in all hypotheses

  SE = 0;
  IE = 0;
  DE = 0;
  LEV_DIST = 0;

  total_wordcount = 0;

  hypothesis_text = textread(hypothesis, '%s', 'delimiter', '\n');
  for hyp_index=1:length(hypothesis_text)
    split_hyp = regexp(hypothesis_text{hyp_index}, '\s', 'split');
    hyp_sentence = split_hyp(3:end);
    m = length(hyp_sentence);

    ref_filename = strcat('unkn_%s.txt', num2str(hyp_index));
    ref_text = textread([annotation_dir, filesep, ref_filename], '%s', 'delimiter', '\n');
    split_ref = regexp(ref_text{1}, '\s', 'split');
    ref_sentence = split_ref(3:end);
    n = length(ref_sentence);

    total_wordcount = total_wordcount + n;

    distance_matrix = zeros(n + 1, m + 1);
    backtracking_matrix = zeros(n + 1, m + 1);

    distance_matrix(1, :) = Inf;
    distance_matrix(:, 1) = Inf;
    distance_matrix(1, 1) = 0;

    for i=2:n+1
      for j=2:m+1
        del = distance_matrix(i - 1, j) + 1;

        sub_modifier = 1;
        if strcmp(ref_sentence{i - 1}, hyp_sentence{j - 1})
          sub_modifier = 0;
        end
        sub = distance_matrix(i - 1, j - 1) + sub_modifier;

        ins = distance_matrix(i, j - 1) + 1;

        distance_matrix(i, j) = min(del, sub, ins);

        if distance_matrix(i. j) == del
          backtracking_matrix(i, j) = 'up';
        elseif distance_matrix(i, j) == ins
          backtracking_matrix(i, j) = 'left';
        else
          backtracking_matrix(i, j) = 'up-left';
        end
      end
    end
    LEV_DIST = LEV_DIST + (100*distance_matrix(n, m)/n);

    % count new IE, DE and SEs
    flat_backtracking_matrix = backtracking_matrix(:)';
    for index=1:length(flat_backtracking_matrix)
      if strcmp(flat_backtracking_matrix(index), 'up-left')
        SE = SE + 1;        
      elseif strcmp(flat_backtracking_matrix(index), 'up')
        DE = DE + 1;
      elseif strcmp(flat_backtracking_matrix(index), 'left')
        IE = IE + 1;
      end
    end
  end

  SE = SE / total_wordcount;
  IE = IE / total_wordcount;
  DE = DE / total_wordcount;
end

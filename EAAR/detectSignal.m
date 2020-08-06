function [det, m_cc, ratio] = detectSignal(cc)
%     idx = find(cc > 1e-8);
%     mycc = cc(idx(1):end);
%     plot(mycc);
%     m_cc = max(mycc);
    m_cc = max(cc);
    avg_cc = mean(abs(cc));
    std_cc = std(cc);
    ratio = m_cc/(avg_cc+std_cc);
    if ratio > 8
        det = true;
    else
        det = false;
    end
%     disp('m_cc');
%     disp(m_cc);
%     disp('ratio');
%     disp(ratio);
end
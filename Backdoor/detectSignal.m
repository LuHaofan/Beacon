function [det, m_cc] = detectSignal(cc)
    idx = find(cc > 1e-8);
    mycc = cc(idx(1):length(cc));
    %figure; plot(mycc);
    m_cc = max(mycc);
    avg_cc = mean(abs(mycc));
    ratio = m_cc/avg_cc;
    if ratio > 6
        det = true;
    else
        det = false;
    end
end
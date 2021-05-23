function dis = EuclDist(p,q)
    dis  = sqrt(sum((p - q) .^ 2));        
end
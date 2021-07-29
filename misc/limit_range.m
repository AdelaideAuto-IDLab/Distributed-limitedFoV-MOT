function clipped_r= limit_range(r)
    r(r>0.999)=0.999;
    r(r<eps)=eps;
    clipped_r= r;
end
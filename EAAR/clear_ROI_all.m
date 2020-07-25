k=1;
while k<=length(ROI_obj)
    obj = ROI_obj(k);
    AAR_loc(obj.ptr,4) = 0;
    ROI_obj(k)=[];
end